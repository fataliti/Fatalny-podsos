package events;

import com.raidandfade.haxicord.types.structs.Status;
import com.raidandfade.haxicord.types.structs.Status.Activity;
import haxe.rtti.Meta;

class OnReady {
    public static function onReady() {
        CompileTime.importPackage("commands");
        var classList = CompileTime.getAllClasses("commands");
        //trace(classList);
        var statics;
        for (_class in classList) {
            statics = Meta.getStatics(_class);
            //trace(statics);

            for(s in Reflect.fields(statics)) {
                //trace(s);

                if (s == "initialize") {
                    Reflect.callMethod(_class, Reflect.field(_class,s),[]);
                    continue;
                }
                if (s == "down" || s == "rectionAdd" ) 
                    continue;

                var field = Reflect.field(statics, s);
                //trace(field);
                var names:Array<String> = field.command[0];
                for(name in  names) {
                    var command:Bot.Command = {_class:_class, command: s}
                    Bot.commandMap.set(name, command);
                }
            } 
        }

        var a:Activity = {
            name: "!info",
            type: 0,
        };
        var s:Status = {
            game: a,
            afk: false,
            status: "online",
        };
        Bot.bot.setStatus(s);


        trace("On ready!");
    }
}