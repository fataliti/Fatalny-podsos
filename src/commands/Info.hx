package commands;

import com.raidandfade.haxicord.types.Message;

class Info {

    @command(["about"], "Информация про бота")
    public static function about(m:Message) {
        
    }

    @command(["info", "help"], "Помощь по командам")
    public static function help(m:Message, words:Array<String>) {
        if (words.length > 0) {
            
        } else {

        }
    }
}