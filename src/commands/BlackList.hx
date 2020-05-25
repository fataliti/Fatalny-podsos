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

    @command(["radd","add","добавить"],"Добавить теги в черный список сервера")
    public static function add(m:Message, words:Array<String>) {
        if (m.hasPermission(DPERMS.MANAGE_CHANNELS)) {

            if (!blackLists.exists(m.getGuild().id.id)) {
                blackLists.set(m.getGuild().id.id, []);
            }

            var list = blackLists.get(m.getGuild().id.id);
            for(w in words){
                if (list.indexOf(w) == -1) {
                    list.push(w);
                    Tools.sendMessage('$w добавил в блеклист', m.channel_id.id);
                }
            } 
        } else 
            Tools.reply(m, "У тебя нет права для изменения блеклиста");
    }

    @command(["rdel","del","удалить"],"Удалить теги из черного списка сервера")
    public static function del(m:Message, words:Array<String>) {
        if (m.hasPermission(DPERMS.MANAGE_CHANNELS)) {
            if (!blackLists.exists(m.getGuild().id.id)) 
                return;
            
            var list = blackLists.get(m.getGuild().id.id);
            for(w in words){
                if (list.remove(w))
                    Tools.sendMessage('$w удалил из блеклиста', m.channel_id.id);
            }    
        } else 
            Tools.reply(m, "У тебя нет права для изменения блеклиста");
    }


    @command(["blacklist", "list", "rlist","список","лист"],"Показать черный список тегов сервера")
    public static function list(m:Message) {
        if (blackLists.exists(m.getGuild().id.id)) {
            Tools.sendMessage("Черный список тегов сервера: "+ blackLists.get(m.getGuild().id.id).toString(), m.channel_id.id);
        } else 
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

