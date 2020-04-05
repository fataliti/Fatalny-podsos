
import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.endpoints.Endpoints;

import haxe.Http;
import haxe.Json;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.DiscordClient;


class Main {
    static var bot:DiscordClient;
    static var pref:String  = "!";
    static var token:String = "NjY2Mjk5MTM0NTc5NDQxNjY0.Xm3FkQ.qgW0_zAC3yrjBBEerfd3KFo3Vmo"; 

    static function main() {
        bot = new DiscordClient(token);
        bot.onMessage = onMessage;
        bot.onReady = onReady;
    }

    public static function onMessage(m:Message) {
        if (StringTools.startsWith(m.content, "!")) {
            var words:Array<String> = m.content.split(" ");

            if (words.shift() == '${pref}r34') {

                var find = "https://r34-json-api.herokuapp.com/posts?tags=";
                for(w in words)
                    find += w + "+";

                var rget = new Http(find);
                rget.onData = function (data:String) {

                    var jlist:Array<Dynamic> = Json.parse(data); 
                    var r = Math.ceil(Std.random(jlist.length));

                    var choose = jlist[r];
                    if (choose != null) { 
                        trace(choose.file_url);
                        
                        var nm = StringTools.replace(choose.file_url, "https://r34-json-api.herokuapp.com/images?url=","");
                        var xx:MessageCreate = {
                            content: nm
                        };
                        var ss = new Endpoints(bot);
                        ss.sendMessage(m.channel_id.id, xx);
                    } else {
                        var xx:MessageCreate = {
                            content: "ничего не нашел"
                        };
                        var ss = new Endpoints(bot);
                        ss.sendMessage(m.channel_id.id, xx);
                    }

                    
                }
                rget.onError = function (error) {
                    trace('error: $error  Произошел тролинк');
                }

                rget.request();

                trace("r34 command");
                trace(words.toString());
            } else {
                trace("not command");
            }
        }
    }

    public static function onReady() {
        trace('invite link: ${bot.getInviteLink()}');
    }
    
}