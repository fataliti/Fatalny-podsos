
import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.endpoints.Endpoints;

import haxe.Http;
import haxe.Json;
import haxe.Timer;

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
        if (StringTools.startsWith(m.content, pref)) {
            var words:Array<String> = m.content.split(" ");

            var command = words.shift();


            if (command == '${pref}r') {  
                
                //trace('command detect: ${words.toString()}');

                var find = "https://r34-json-api.herokuapp.com/posts?tags=";
                for(w in words)
                    find += w + "+";

                var rget = new Http(find);
                rget.onData = function (data:String) {  
                    //trace("data get");

                    var jlist:Array<Dynamic> = Json.parse(data); 
                    var blacklist:Array<String> = R34.blackList;

                    var r = Math.ceil(Std.random(jlist.length));
                    var choose:RFile = jlist[r];
                    
                    if (choose != null) { 
                        var taglist:Array<String> = choose.tags;
                    
                        var finding = true;
                        while (finding == true)  {
                            //trace(r);
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
                                sendMessage(nm, m.channel_id.id);
                            }
                            else {
                                if (++r < jlist.length) {
                                    choose = jlist[r];
                                    taglist = choose.tags;
                                } else {
                                    finding = false;
                                    sendMessage("мне нельзя такое показывать", m.channel_id.id);
                                }
                            }
                        }         
                    } else {
                        sendMessage("ничего не нашел", m.channel_id.id);
                    }
                }

                rget.request();
                
            } 
        }
    }

    public static function onReady() {
        trace('invite link: ${bot.getInviteLink()}');


        var timer:haxe.Timer = new haxe.Timer(60 * 1000 * 10);
        timer.run = function() 
        {   
            var animeChan = "638490021678284820";
            var page = Std.random(40);
            //trace(page);
            var find = "https://r34-json-api.herokuapp.com/posts?tags=cute+solo+female&pid="+Std.string(page);
            var rget = new Http(find);
            rget.onData = function (data:String)
            {
                var jlist:Array<Dynamic> = Json.parse(data);
                var blacklist:Array<String> = R34.blackList;
                blacklist.push("girly");

                var r = Math.ceil(Std.random(jlist.length));
                var choose:RFile = jlist[r];
                if (choose != null) { 
                    var taglist:Array<String> = choose.tags;
                
                    var finding = true;
                    while (finding == true)  {
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
                            sendMessage(nm + " " + taglist.toString(), animeChan);
                        }
                        else {
                            if (++r < jlist.length) {
                                choose = jlist[r];
                                taglist = choose.tags;
                            } else {
                                finding = false;
                            }
                        }
                    }  
                } 
            }
            rget.request();
        }  


    }
    


    public static function sendMessage(text:String, channleId:String) {
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
    /*
    var height:String;
    var parent_id:String;
    var sample_url:String;
    var sample_width
    var sample_height
    var preview_url
    var rating
    var id
    var width
    var change
    var md5
    var creator_id
    var has_children
    var created_at
    var status
    var source
    var has_notes
    var has_comments
    var preview_width
    var preview_height
    var comments_url
    var type
    var creator_url
    */
}



class R34 {
    //public var commandName:String;
    //public var info:String;
    //public var allowedChannels:Array<String>;
    //public var permission:Array<String>;
    
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

/*
    public static function rPost(m:Message, words:Array<String>) {
        var find = "https://r34-json-api.herokuapp.com/posts?tags=";
        for(w in words)
            find += w + "+";

        var rget = new Http(find);
        rget.onData = function (data:String) {  
            //trace("data get");

            var jlist:Array<Dynamic> = Json.parse(data); 
            var blacklist:Array<String> = R34.blackList;

            var r = Math.ceil(Std.random(jlist.length));
            var choose:RFile = jlist[r];
                    
            if (choose != null) { 
                var taglist:Array<String> = choose.tags;
                    
                var finding = true;
                while (finding == true)  {
                    //trace(r);
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
                        Main.sendMessage(nm, m.channel_id.id);
                    }
                    else {
                        if (++r < jlist.length) {
                            choose = jlist[r];
                            taglist = choose.tags;
                        } else {
                            finding = false;
                            Main.sendMessage("мне нельзя такое показывать", m.channel_id.id);
                        }
                    }
                }         
            } else {
                Main.sendMessage("ничего не нашел", m.channel_id.id);
            }
        }

        rget.request();
    }
  */  
}