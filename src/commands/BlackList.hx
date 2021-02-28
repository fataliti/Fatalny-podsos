package commands;

import sys.db.Sqlite;
import sys.FileSystem;
import sys.io.File;
import com.raidandfade.haxicord.utils.DPERMS;
import com.raidandfade.haxicord.types.Message;

import haxe.Json;

@desc("BlackList","Модуль черного списка")
class BlackList {

    public static var blackLists:Map<String,Array<String>> = new Map(); 

    @initialize 
    public static function initialize() {

        Bot.db.request("
            CREATE TABLE IF NOT EXISTS 'blacklist' (	
                'id' INTEGER PRIMARY KEY AUTOINCREMENT,
                'servId' TEXT, 
                'word' TEXT
            )
        ");

        var list = Bot.db.request('SELECT servId, word FROM blacklist');
        for (pos in list) {
            if (blackLists[pos.servId] == null) {
                blackLists[pos.servId] = [];
            } 
            blackLists[pos.servId].push(pos.word);
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

    @command(["add"],"Добавить теги в черный список сервера","?теги")
    public static function add(m:Message, words:Array<String>) {
        
        var _id:String = chekId(m);
        if (_id == null)
            return;

        if (!blackLists.exists(_id)) {
            blackLists.set(_id, []);
        }

        var list= blackLists.get(_id);
        for(w in words){
            if (list.indexOf(w) == -1) {
                list.push(w);
                Bot.db.request('INSERT INTO blacklist(servId, word) VALUES("${_id}","${w}")');
            }
        } 
        var j = list.join(' ');
        Tools.sendMessage('Текущий блеклист: `${j}`', m.channel_id.id);
    }

    @command(["del"],"Удалить теги из черного списка сервера", "?теги")
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
                Bot.db.request('DELETE FROM blacklist WHERE servId = "${_id}" AND word = "${w}"');
        }    
        var j = list.join(' ');
        Tools.sendMessage('Текущий блеклист: `${j}`', m.channel_id.id);
    }

    @command(["blacklist", "list",],"Показать черный список тегов сервера")
    public static function blacklist(m:Message) {
        var _id = m.inGuild() ? m.getGuild().id.id : m.author.id.id;
        if (blackLists.exists(_id)) {
            var j = blackLists[_id].join(' ');
            Tools.sendMessage('Текущий блеклист: `${j}`', m.channel_id.id);
        } else {
            Tools.reply(m, "Блеклиста нету");
        }
    }


}

