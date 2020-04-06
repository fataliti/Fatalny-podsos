
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
            trace("timerdone");
            var page = Std.random(100);
            trace(page);
            var find = "https://r34-json-api.herokuapp.com/posts?tags=&pid="+Std.string(page);
            var rget = new Http(find);
            rget.onData = function (data:String)
            {
                var jlist:Array<Dynamic> = Json.parse(data);
                var blacklist:Array<String> = R34.blackList;
                var r = Math.ceil(Std.random(jlist.length));
                var choose:RFile = jlist[r];
                trace("i am here");
                if (choose != null) { 
                    var taglist:Array<String> = choose.tags;
                
                    var finding = true;
                    while (finding == true)  {
                        trace("i have come");
                        var fail = false;
                        for (tag in taglist)
                        {   
                            var result:Int = blacklist.indexOf(tag);
                            if (result >= 0) {
                                fail = true;
                                break;
                            }
                        } 

                        if (!fail) {
                            finding = false;
                            var nm = StringTools.replace(choose.file_url, "https://r34-json-api.herokuapp.com/images?url=","");
                            trace("bitch");
                            sendMessage(nm, "696397752611111012");
                        }
                        else {
                            if (++r < jlist.length) {
                                choose = jlist[r];
                                taglist = choose.tags;
                            } else {
                                finding = false;
                                sendMessage("мне нельзя такое показывать", "696397752611111012");
                            }
                        }
                    }         
                } else {
                    sendMessage("ничего не нашел", "696397752611111012");
                }
            }
        }           
    }
    public static function sendMessage(text:String, channleId:String) 
    {
        var msg:MessageCreate = {
            content: text
        };
        var end = new Endpoints(bot);
        end.sendMessage(channleId, msg);
    }
}



typedef RFile = {
var score:String;
var file_url:String;
var tags:Array<String>;
}
class R34 
{
    public static var blackList:Array<String> = [
        "futanari",
        "big_belly",
        "rimming",
        "hyper",
        "inflation",
        "lactating",
        "male/male",
        "male_on_feral",
        "pooping",
        "score:0",
        "urine",
        "belly_hair",
        "chest_hair",
        "slightly_chubby",
        "overweight",
        "big_muscles",
        "human_penetrating_feral"
    ];
}