package events;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.structs.Emoji;

import haxe.rtti.Meta;

class OnReactionAdd {
    public static function onReactionAdd(m:Message, u:User, e:Emoji) {
        var classes = CompileTime.getAllClasses("commands");

        for (_class in classes) {
            var statics = Meta.getStatics(_class);
            for(s in Reflect.fields(statics)) {
                if (s == "rectionAdd") {
                    Reflect.callMethod(_class, Reflect.field(_class, s), [m, u , e]);
                }
            }
        }
    }  
}