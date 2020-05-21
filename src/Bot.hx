

import com.raidandfade.haxicord.DiscordClient;
import com.raidandfade.haxicord.types.Message;


import haxe.rtti.Meta;

import Tools;

class Bot {

    public static var bot(default,null):DiscordClient;
    static var token:String = "NjY2Mjk5MTM0NTc5NDQxNjY0.Xm3FkQ.qgW0_zAC3yrjBBEerfd3KFo3Vmo";
    static var pref = "!";

    static var commandMap:Map<String,Command> = new Map();


    public static function main() {
        bot = new DiscordClient(token);
        bot.onMessage = onMessage;
        bot.onReady = onReady;
        loadCommands();
    }

    public static function onReady() {
        trace("work started");
    }

    public static function loadCommands() {
        CompileTime.importPackage("commands");
        var classList = CompileTime.getAllClasses("commands");
        trace(classList);
        var statics;

        for (_class in classList) {
            statics = Meta.getStatics(_class);
            trace(statics);

            for(s in Reflect.fields(statics)) {
                trace(s);
                if (s == "initialize") {
                    Reflect.callMethod(_class, Reflect.field(_class,s),[]);
                    continue;
                }

                var field = Reflect.field(statics, s);
                trace(field);
                var names:Array<String> = field.command[0];
                for(name in  names) {
                    var command:Command = {_class:_class, command: s}
                    commandMap.set(name, command);
                }
            } 
        }

    }


    
    public static function onMessage(m:Message) {
        if (StringTools.startsWith(m.content, pref)) {
            var words:Array<String> = m.content.split(" ");
            var comName = words.shift();
            comName = StringTools.replace(comName, pref, "");
            if (commandMap.exists(comName)) {
                
                var command:Command = commandMap.get(comName);
                trace("Called " +command);
                Reflect.callMethod(command._class, Reflect.field(command._class,command.command),[m, words]);
/*
                if (m.inGuild())
                    stat.reqvSV++;
                else 
                    stat.reqvLS++;
*/                
                //Reflect.callMethod(Main, Reflect.field(Main,commandList[c]),[m, words]);
            }
        }
    }
    

}



typedef Command = {
    var _class:Class<Dynamic>;
    var command:String;
}