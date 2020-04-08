import com.raidandfade.haxicord.types.structs.Status;
import com.raidandfade.haxicord.types.structs.Embed;
import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.endpoints.Endpoints;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.DiscordClient;


import haxe.Http;
import haxe.Json;
import haxe.Timer;
import haxe.rtti.Meta;

import sys.FileSystem;
import sys.io.File;


class Main {
    static var bot:DiscordClient;
    static var pref:String  = "!";
    static var token:String = "NjY2Mjk5MTM0NTc5NDQxNjY0.Xm3FkQ.qgW0_zAC3yrjBBEerfd3KFo3Vmo"; 
    static var commandList:Array<String> = [];

    static var rssLink:String;
    static var rssPage:Int;
    
    static function main() {
        bot = new DiscordClient(token);
        bot.onMessage = onMessage;
        bot.onReady = onReady;
        bot.ws.onClose = onClose;

        if (FileSystem.exists("mlist.txt")) {
            var mt = File.getContent("mlist.txt");
            var mj:Array<String> = Json.parse(mt);
            for(tag in mj) {
                if (R34.blackList.indexOf(tag) == -1) {
                    R34.blackList.push(tag);
                }
            }
        }

        if (FileSystem.exists("rss.txt")) {
            var rt = File.getContent("rss.txt");
            var rj:RSSFile = Json.parse(rt);
            rssLink = rj.tags;
            rssPage = rj.page;
        } else {
            rssLink = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=score:20+1girl&page=";
            rssPage = 200;
        }

        var statics = Meta.getStatics(Main);
        for(s in Reflect.fields(statics)) {
            commandList.push(s);
        }

        trace("all ready");
    }

    public static function onReady() {
        trace('invite link: ${bot.getInviteLink()}');

        var a:Activity = {
            name: "!info",
            type: 0,
        };
        var s:Status = {
            game: a,
            afk: false,
            status: "online",
        };

        bot.setStatus(s);

        var timer:Timer = new Timer(60 * 1000 * 10);
        timer.run = function() 
        {   
            var animeChan = "638490021678284820";
            var page = Std.random(rssPage);
            var find = rssLink+Std.string(page);
            var rget = new Http(find);
            
            rget.onData = function (data:String) {  
                var jlist:GFile = Json.parse(data); 
                var blacklist:Array<String> = R34.blackList;

                var r = Math.ceil(Std.random(jlist.count));
                var choose = jlist.posts[r];
                        
                if (choose != null) { 
                    var taglist:Array<String> = choose.tags.split(" ");
                        
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
                            Main.sendMessage(choose.file_url, animeChan);
                        }
                        else {
                            if (++r < jlist.count) {
                                choose = jlist.posts[r];
                                taglist = choose.tags.split(" ");
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
        var j = Json.stringify(R34.blackList);
        File.saveContent("mlist.txt", j);

        var rs:RSSFile = {tags:rssLink, page:rssPage};
        var rj = Json.stringify(rs);
        File.saveContent("rss.txt",rj);

        trace("ya ypal");
        Sys.exit(228);
    }

    public static function sendMessage(text:String, channleId:String) {
        var msg:MessageCreate = {
            content: text
        };
        var end = new Endpoints(bot);
        end.sendMessage(channleId, msg);
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
                if (m.inGuild())
                    sendMessage('||$nm ||', m.channel_id.id);   
                else 
                    sendMessage(nm, m.channel_id.id);  
            } else {
                sendMessage("ничего не нашел", m.channel_id.id);
            }
        }
        rget.request();
    }

    @Command 
    public static function rlist(m:Message) {
        sendMessage(R34.blackList.toString(), m.channel_id.id);
    }

    
    @Command 
    public static function g(m:Message, words:Array<String>) {

        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            var jlist:GFile = Json.parse(data); 
            var blacklist:Array<String> = R34.blackList;

            var r = Math.ceil(Std.random(jlist.count));
            var choose = jlist.posts[r];
                    
            if (choose != null) { 
                var taglist:Array<String> = choose.tags.split(" ");
                    
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
                        Main.sendMessage(choose.file_url, m.channel_id.id);
                    }
                    else {
                        if (++r < jlist.count) {
                            choose = jlist.posts[r];
                            taglist = choose.tags.split(" ");
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
    public static function ga(m:Message, words:Array<String>) {

        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            var jlist:GFile = Json.parse(data); 
            var blacklist:Array<String> = R34.blackList;

            var r = Math.ceil(Std.random(jlist.count));
            var choose = jlist.posts[r];
                    
            if (choose != null) { 
                if (m.inGuild())
                    Main.sendMessage("||"+choose.file_url+" ||", m.channel_id.id);
                else 
                    Main.sendMessage(choose.file_url, m.channel_id.id);
            } else {
                Main.sendMessage("ничего не нашел", m.channel_id.id);
            }
        }

        rget.request();
    }

    @Command
    public static function info(m:Message) {
        var aut:EmbedAuthor = {
            name: "Fatalny_podsos",
            icon_url: bot.user.avatarUrl,
        }

        var f1:EmbedField = {
            name: "r теги через пробел",
            value: "Показывает случайную пикчу с заданными тегами c rule34.xxx. имена персонажей указывать одним тегом через нижний прочерк onigawara_rin, нежелательные варианты отсеиваются черным списком",        
        };
        
        var f2:EmbedField = {
            name: "ra теги через пробел",
            value: "аналогично команде r, но без черного списка, однако результат будет под спойлером. в лс спойлеров не будет",      
        };

        var f11:EmbedField = {
            name: "g теги через пробел",
            value: "Показывает случайную пикчу с заданными тегами c gelbooru.com. имена персонажей указывать одним тегом через нижний прочерк onigawara_rin, нежелательные варианты отсеиваются черным списком",        
        };
        
        var f21:EmbedField = {
            name: "ga теги через пробел",
            value: "аналогично команде g, но без черного списка, однако результат будет под спойлером. в лс спойлеров не будет",      
        };
        
        var f3:EmbedField = {
            name: "rlist",
            value: "черный список тегов"
        };

        var embed:Embed = {
            author: aut,
            fields: [f1,f2,f11,f21,f3],
            color: 0,
        };
    
        var msg:MessageCreate = {
            embed: embed,
        };
        var end = new Endpoints(bot);
        end.sendMessage(m.channel_id.id, msg);
    }
   

    @Command 
    public static function status(m:Message, words:Array<String>) {
        if (m.getMember().user.id.id != "371690693233737740")
            return;
        
        var a:Activity = {
            name: words.join(" "),
            type: 0,
        };
        var s:Status = {
            game: a,
            afk: false,
            status: "online",
        };

        bot.setStatus(s);
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
    public static function rss_link(m:Message, words:Array<String>) {
        if (m.getMember().user.id.id != "371690693233737740")
            return;
        rssLink = words.shift();
        sendMessage('автопост по ссылке `$rssLink`', m.channel_id.id);
    }
    @Command
    public static function rss_page(m:Message, words:Array<String>) {
        if (m.getMember().user.id.id != "371690693233737740")
            return;
        rssPage = Std.parseInt(words.shift());
        sendMessage('автопост из `$rssPage` страниц', m.channel_id.id);
    }
    @Command
    public static function rss_info(m:Message) {
        sendMessage('автопост по ссылке `$rssLink$rssPage`', m.channel_id.id);
    }

}


typedef RFile = {
    var score:String;
    var file_url:String;
    var tags:Array<String>;
}

typedef GFile = {
    var total:Int;
    var count:Int;
    var page:Int;
    var posts:Array<{score:String, file_url:String, rating:String, tags:String, id:String}>;
}

typedef RSSFile = {
    var page:Int;
    var tags:String;
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
        "girly",
    ];
}