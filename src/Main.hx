


import sys.FileSystem;
import sys.io.File;
import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.endpoints.Endpoints;

import haxe.Http;
import haxe.Json;
import haxe.Timer;


import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.DiscordClient;

import haxe.rtti.Meta;



class Main {
    static var bot:DiscordClient;
    static var pref:String  = "!";
    static var token:String = "NjY2Mjk5MTM0NTc5NDQxNjY0.Xm3FkQ.qgW0_zAC3yrjBBEerfd3KFo3Vmo"; 
    static var commandList:Array<String> = [];

    
    static function main() {
        bot = new DiscordClient(token);
        bot.onMessage = onMessage;
        bot.onReady = onReady;
        bot.ws.onClose = onClose;

        if (FileSystem.exists("mlist.txt")) {
            var t = File.getContent("mlist.txt");
            var j:Array<String> = Json.parse(t);
            for(tag in j) {
                if (R34.blackList.indexOf(tag) == -1) {
                    R34.blackList.push(tag);
                }
            }
        }

        var statics = Meta.getStatics(Main);
        for(s in Reflect.fields(statics)) {
            commandList.push(s);
        }

        trace("all ready");
    }


    @Command
    public static function r(m:Message, words:Array<String>) {

        var find = "https://r34-json-api.herokuapp.com/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            var jlist:Array<Dynamic> = Json.parse(data); 
            var blacklist:Array<String> = R34.blackList;

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

    @Command 
    public static function ra(m:Message, words:Array<String>) {
        var find = "https://r34-json-api.herokuapp.com/posts?tags=";
        for(w in words)
            find += "+" + w;
        var rget = new Http(find);
        rget.onData = function (data:String) {  
            var jlist:Array<Dynamic> = Json.parse(data); 
            var r = Math.ceil(Std.random(jlist.length));
            var choose:RFile = jlist[r];  
            if (choose != null) { 
                var nm = StringTools.replace(choose.file_url, "https://r34-json-api.herokuapp.com/images?url=","");
                sendMessage('|| $nm ||', m.channel_id.id);    
            } else {
                sendMessage("ничего не нашел", m.channel_id.id);
            }
        }
        rget.request();
    }

    @Command
    public static function rdel(m:Message, words:Array<String>) {
        if (m.getMember().user.id.id != "371690693233737740")
            return;

        for(w in words){
            if (w != "") {
                R34.blackList.remove(w);
                sendMessage('$w удалил из блеклиста', m.channel_id.id);
            }
        }
    }

    @Command 
    public static function radd(m:Message, words:Array<String>) {
        if (m.getMember().user.id.id != "371690693233737740")
            return;

        for(w in words){
            if (w != "" && R34.blackList.indexOf(w) == -1) {
                R34.blackList.push(w);
                sendMessage('$w добавил в блеклист', m.channel_id.id);
            }
        }
    }

    @Command 
    public static function rlist(m:Message) {
        sendMessage(R34.blackList.toString(), m.channel_id.id);
    }

    public static function onMessage(m:Message) {
        if (StringTools.startsWith(m.content, pref)) {
            var words:Array<String> = m.content.split(" ");

            var command = words.shift();
            command = StringTools.replace(command, pref, "");
            
            var c = commandList.indexOf(command);
            if (c >= 0) {
                Reflect.callMethod(Main, Reflect.field(Main,commandList[c]),[m, words]);
            }
        }
    }

    public static function onReady() {
        trace('invite link: ${bot.getInviteLink()}');


        var timer:haxe.Timer = new haxe.Timer(60 * 1000 * 10);
        timer.run = function() 
        {   
            var animeChan = "638490021678284820";
            var page = Std.random(5);
            var find = "https://r34-json-api.herokuapp.com/posts?tags=cute+female+human&pid="+Std.string(page);
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
                            sendMessage(nm, animeChan);
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
    
    public static function onClose(c:Int) {
        var j = haxe.Json.stringify(R34.blackList);
        File.saveContent("mlist.txt", j);
        trace("server ypal");

        Sys.exit(228);
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
}



class R34 {
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
        "human_penetrating_feral",
        "dickgirl",
        "1futa",
        "gay",
        "yaoi",
        "cyclops",
        "chubby",
        "feral",
        "anthro",
        "girly"
    ];
}