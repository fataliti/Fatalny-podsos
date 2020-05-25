import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.endpoints.Endpoints;

import haxe.rtti.Meta;

class Tools {


    public static function sendMessage(text:String, channleId:String) {
        var msg:MessageCreate = {
            content: text
        };
        var end = new Endpoints(Bot.bot);
        end.sendMessage(channleId, msg);
    }

    public static function reply(m:Message, text:String) {
        m.reply({content: '<@${m.author.id.id}> ${text}'});
    }

    public static function saveData() {
        var classes = CompileTime.getAllClasses("commands");

        for (_class in classes) {
            var statics = Meta.getStatics(_class);
            for(s in Reflect.fields(statics)) {
                if (s == "down") {
                    Reflect.callMethod(_class, Reflect.field(_class, s), []);
                }
            }
        }
    }
}