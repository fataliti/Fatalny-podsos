import sys.db.Sqlite;
import com.raidandfade.haxicord.DiscordClient;
import sys.db.Connection;

import Tools;
import events.*;

class Bot {
    public static var db:Connection;
    public static var bot:DiscordClient;
    public static var token:String = "NjY2Mjk5MTM0NTc5NDQxNjY";
    public static var prefix = "$";

    public static var commandMap:Map<String,Command> = new Map();

    public static function main() {
        bot = new DiscordClient(token);
        bot.onMessage = OnMessage.onMessage;
        bot.onReactionAdd = OnReactionAdd.onReactionAdd;
        bot.onReactionRemove = OnReactionDel.onReactionDel;
        bot.ws.onClose = OnClose.onClose;
        bot.onReady = OnReady.onReady;

        
        db = Sqlite.open("podsos.db");
    }
}

typedef Command = {
    var _class:Class<Dynamic>;
    var command:String;
}

