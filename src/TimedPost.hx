
import cpp.Random;
import haxe.Timer;
import haxe.display.JsonModuleTypes.JsonTodo;
import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.endpoints.Endpoints;

import haxe.Http;
import haxe.Json;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.DiscordClient;

class TimedPost
{
    static var bot:DiscordClient;
    static var pref:String  = "!";
    static var token:String = "Njk2MzkwMzcwMTcwMzcyMTI3.XooCIg.DZJV87uglY8eEEqNJxNqaGc97fk"; 

    static function main() {
    bot = new DiscordClient(token);
    bot.onReady = onReady;
    }

    public static function onReady() 
    {       
        trace('invite link: ${bot.getInviteLink()}');
        var timer:haxe.Timer = new haxe.Timer(10000);
        timer.run = function() 
        {
            var r = 0;
            trace("timerdone");
            var page = Std.random(100);
            trace(page);
            var find = "https://r34-json-api.herokuapp.com/posts?tags=&pid="+Std.string(page);
            var rget = new Http(find);
            rget.onData = function (data:String)
            {
                var jlist:Array<Dynamic> = Json.parse(data);
                r = Math.ceil(Std.random(jlist.length));
                var choose = jlist[r];
                var taglist:Array<String> = choose.tags;
                /*var blacklist:Array<String> = [];
                for (tag in taglist)
                {
                    var result:Int = blacklist.indexOf(tag);
                    switch(result)
                    {
                        case -1: trace("good");
                        default: trace("ah! this is not good. should reroll");
                    }
                } */
                if (choose != null) 
                { 
                    trace(choose.file_url);
                        
                    var nm = StringTools.replace(choose.file_url, "https://r34-json-api.herokuapp.com/images?url=","");
                    var xx:MessageCreate = {
                        content: nm
                    };
                    var ss = new Endpoints(bot);
                    ss.sendMessage("696397752611111012", xx);
                }
            }
            rget.request();
        }           
    } 
}