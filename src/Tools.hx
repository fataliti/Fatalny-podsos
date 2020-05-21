import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.endpoints.Endpoints;

class Tools {


    public static function sendMessage(text:String, channleId:String) {
        var msg:MessageCreate = {
            content: text
        };
        var end = new Endpoints(Bot.bot);
        end.sendMessage(channleId, msg);
    }

    public static function reply(m:Message, text:String) {
        m.reply({content: text});
    }

}