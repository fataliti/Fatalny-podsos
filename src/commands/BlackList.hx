package commands;

import sys.FileSystem;
import sys.io.File;
import com.raidandfade.haxicord.utils.DPERMS;
import com.raidandfade.haxicord.types.Message;

import haxe.Json;

class BlackList {

    public static var blackLists:Map<String,Array<String>> = new Map(); 

    @initialize 
    public static function initialize() {
        if (FileSystem.exists("blackLists.txt")) {
            var saveData:Array<Array<String>> = Json.parse(File.getContent("blackLists.txt"));
            for(array in saveData) {
                var serverId = array.shift();
                blackLists.set(serverId, array);
            }
        } 
    }

    static function chekId(m:Message):String {
        if(m.inGuild()) {
            if (!m.hasPermission(DPERMS.MANAGE_CHANNELS)) {
                Tools.reply(m, "У тебя нет права для изменения блеклиста");
                return null;
            }
            return m.getGuild().id.id;
        } else 
            return m.author.id.id;
    }

    @command(["add"],"Добавить теги в черный список сервера","теги")
    public static function add(m:Message, words:Array<String>) {
        
        var _id:String = chekId(m);
        if (_id == null)
            return;

        if (!blackLists.exists(_id)) {
            blackLists.set(_id, []);
        }

        var list = blackLists.get(_id);
        for(w in words){
            if (list.indexOf(w) == -1) {
                list.push(w);
                Tools.sendMessage('$w добавил в блеклист', m.channel_id.id);
            }
        } 
    }

    @command(["del"],"Удалить теги из черного списка сервера", "теги")
    public static function del(m:Message, words:Array<String>) {


        var _id:String = chekId(m);
        if (_id == null)
            return;

        if (!blackLists.exists(_id)) {
            Tools.reply(m, "Черный список никогда не создавался, для начала добавь в него что нибудь");
            return;
        }

        var list = blackLists.get(_id);
        for(w in words){
            if (list.remove(w))
                Tools.sendMessage('$w удалил из блеклиста', m.channel_id.id);
        }    

    }

    @command(["blacklist", "list",],"Показать черный список тегов сервера")
    public static function blacklist(m:Message) {
        var _id = m.inGuild() ? m.getGuild().id.id : m.author.id.id;
        if (blackLists.exists(_id)) 
            Tools.sendMessage("Черный список тегов: "+ blackLists.get(_id).join(" "), m.channel_id.id);
         else 
            Tools.reply(m, "Блеклиста нету");
    }

    @down
    public static function down() {
        var saveData:Array<Array<String>> = new Array(); 

        for(key in blackLists.keys()) {
            var array:Array<String> = new Array();
            array.push(key);
            for(tag in blackLists.get(key)) {
                array.push(tag);
            }
            saveData.push(array);
        }

        File.saveContent("blackLists.txt", Json.stringify(saveData));
    }

}

