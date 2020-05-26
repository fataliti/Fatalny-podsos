import com.raidandfade.haxicord.DiscordClient;

import Tools;
import events.*;

class Bot {
    
    public static var bot:DiscordClient;
    public static var token:String = "NjY2Mjk5MTM0NTc5NDQxNjY0.Xm3FkQ.qgW0_zAC3yrjBBEerfd3KFo3Vmo";
    public static var prefix = "!";

    public static var commandMap:Map<String,Command> = new Map();

    public static function main() {
        bot = new DiscordClient(token);
        bot.onMessage = OnMessage.onMessage;
        bot.onReactionAdd = OnReactionAdd.onReactionAdd;
        bot.ws.onClose = OnClose.onClose;
        bot.onReady = OnReady.onReady;
    }

}

typedef Command = {
    var _class:Class<Dynamic>;
    var command:String;
}

