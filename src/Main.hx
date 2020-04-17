import haxe.xml.Parser;
import haxe.xml.Access;

import com.raidandfade.haxicord.utils.DPERMS;
import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.structs.Emoji;
import com.raidandfade.haxicord.types.structs.Status;
import com.raidandfade.haxicord.types.structs.Embed;
import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.endpoints.Endpoints;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.DiscordClient;

import haxe.Http;
import haxe.Json;
import haxe.Timer;
import haxe.rtti.Meta;

import sys.FileSystem;
import sys.io.File;




class Main {

    static var testChan = "651671385566871575";
    static var animeChan = "638490021678284820";

    static var bot:DiscordClient;
    static var pref:String  = "!";
    static var token:String = "NjY2Mjk5MTM0NTc5NDQxNjY0.Xm3FkQ.qgW0_zAC3yrjBBEerfd3KFo3Vmo"; 
    static var commandList:Array<String> = [];
    static var subList:Array<String> = [];

    static var rssLink:String;
    static var rssPage:Int;

    static var trapGames:Map<String,Trapgame> = new Map<String,Trapgame>();
    
    static var stat:Stat;

    static var guidMax:Int = 0;

    static function main() {
        bot = new DiscordClient(token);
        
        stat = {reqvLS: 0, reqvSV: 0};
        if (FileSystem.exists("stat.txt")) {
            var fs = File.getContent("stat.txt");
            stat = Json.parse(fs);
        }

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
            guidMax = rj._guidMax;

            if (rj.chans != null)
                for(ch in rj.chans)
                    subList.push(ch);
        } else {
            rssLink = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=score:20+1girl&page=";
            rssPage = 200;
        }

        trace(guidMax);

        var statics = Meta.getStatics(Main);
        for(s in Reflect.fields(statics)) {
            commandList.push(s);
        }

        bot.onMessage = onMessage;
        bot.onReady = onReady;
        bot.onReactionAdd = onReactionAdd;
        bot.ws.onClose = onClose;
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

        var timer = new Timer(60 * 1000 * 15);
        timer.run = function() 
        {   
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
                            //Main.sendMessage(choose.file_url, animeChan);

                            for(chan in subList) 
                                sendMessage(choose.file_url, chan);
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


        var shikitimer = new Timer(60 * 1000 * 5);
        shikitimer.run = function() {
            news();
        }


        if (guidMax == 0) {
            var rget = new Http("https://shikimori.one/forum/news.rss");
            rget.onData = function(data:String) {
                var xm = Parser.parse(data);
                var acc = new Access(xm.firstElement());
                var ch = acc.node.channel;
                var g = ch.node.item.node.guid.innerData;
                g = StringTools.replace(g,"entry-","");
                var guid = Std.parseInt(g);
                guidMax = guid; 
                trace("new guid get " + guidMax);
            }
            rget.request();
        }
        
    }
    
    public static function onClose(c:Int) {
        var j = Json.stringify(R34.blackList);
        File.saveContent("mlist.txt", j);

        var rs:RSSFile = {tags:rssLink, page:rssPage, chans:subList, _guidMax: guidMax};
        var rj = Json.stringify(rs);
        File.saveContent("rss.txt",rj);

        var sj = Json.stringify(stat);
        File.saveContent("stat.txt", sj);

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

            if (m.inGuild())
                stat.reqvSV++;
            else 
                stat.reqvLS++;

            var words:Array<String> = m.content.split(" ");

            var command = words.shift();
            command = StringTools.replace(command, pref, "");
            
            var c = commandList.indexOf(command);
            if (c >= 0) {
                Reflect.callMethod(Main, Reflect.field(Main,commandList[c]),[m, words]);
            }
        }
    }

    public static function onReactionAdd(m:Message, u:User, e:Emoji) {
        if (trapGames.exists(u.id.id)) {
            var tg = trapGames.get(u.id.id);
            if (tg.messageId == m.id.id) {
                if (e.name == "♂️" || e.name == "♀️") {
                    if (e.name == "♀️" && tg.result == 0) {
                        m.edit({embed: {title: "ВЕРНО!", author: {icon_url: u.avatarUrl, name: u.username }}});
                    } else if (e.name == "♂️" && tg.result == 1) {
                        m.edit({embed: {title: "ВЕРНО!", author: {icon_url: u.avatarUrl, name: u.username }}});
                    } else {
                        m.edit({embed: {title: "НЕТ!", author: {icon_url: u.avatarUrl, name: u.username }}});
                    }
                    tg.t.stop();
                    trapGames.remove(u.id.id);
                }
            }
        }
    }   

    @Command
    public static function sub(m:Message) {
        if (!m.inGuild()){
            m.reply({content: "не работает в лс"});
        } else  {
            if (m.hasPermission(DPERMS.ADMINISTRATOR)) {
                if (subList.indexOf(m.channel_id.id) == -1){
                    m.reply({content: "канал подписался на рассылку"});
                    subList.push(m.channel_id.id);
                } else {
                    m.reply({content: "канал отписался от рассылки"});
                    subList.remove(m.channel_id.id);
                }
            } else {
                m.reply({content: "у тебя не достаточно прав для этой команды"});
            }
        }
    }

    @Command
    public static function sub_info(m:Message) {
        sendMessage('автопост по ссылке `$rssLink[random($rssPage)]`', m.channel_id.id);
    }

    @Command
    public static function play(m:Message) {
        if (!trapGames.exists(m.author.id.id)) {
            var tg:Trapgame = {};
            trapGames.set(m.author.id.id, tg);

            var tgf = function (gm:Message, e:ErrorReport) {

                var gameLinks = [
                    "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=1girl+rating:safe+small_breasts+solo&page=" + Std.string(Std.random(200)),
                    "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=trap+solo+rating:safe&page=" + Std.string(Std.random(90)),
                ];
                
                var itog = Std.random(gameLinks.length);
                var find = gameLinks[itog];
                var rget = new Http(find);

                tg.result = itog;
                tg.messageId = gm.id.id;

                rget.onData = function (data:String) {  
                    var jlist:GFile = Json.parse(data); 
                    var r = Math.ceil(Std.random(jlist.count));
                    var choose = jlist.posts[r];
                            
                    if (choose != null) { 
                        gm.edit({embed: {image: {url: choose.file_url} ,author: {icon_url: m.author.avatarUrl, name: m.author.username }}});
                        gm.react("♂️");
                        gm.react("♀️");
                                
                        var timer = new Timer(1000*30);
                        tg.t = timer;
                        timer.run = function() {
                            gm.edit({embed:{title: "время вышло", author: {icon_url: m.author.avatarUrl, name: m.author.username }}});
                            trapGames.remove(m.author.id.id);
                            timer.stop();
                        }     
                    } else {
                        gm.edit({embed:{title: "игра не состоится", author: {icon_url: m.author.avatarUrl, name: m.author.username }}});
                        trapGames.remove(m.author.id.id);
                    }
                }

                rget.onError = function (error) {
                    gm.edit({embed:{title: "игра не состоится", author: {icon_url: m.author.avatarUrl, name: m.author.username }}});
                    trapGames.remove(m.author.id.id);
                }

                rget.request();
            };

            m.reply({embed:{title: "подготовка", author: {icon_url: m.author.avatarUrl, name: m.author.username }}}, tgf);
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
        
        var ft:EmbedField = {
            name: "trap",
            value: "игра в которой вам нужно угадать мальчик перед вами ии девочка",      
        };

        var s:EmbedField = {
            name: "sub",
            value: "возможность подписать текстовый канал на атвопостинг случайной картинки раз в 10 минут(так же отписаться). у вас должно быть право администора сервера. не работает в лс",      
        };

        var si:EmbedField = {
            name: "sub_info",
            value: "узнать что же может запоститься(осторожно JSON)",      
        };

        var f3:EmbedField = {
            name: "rlist",
            value: "черный список тегов"
        };

        var inv:EmbedField = {
            name: "invite",
            value: "ссылка для приглашения бота к себе на сервер"
        };

        var embed:Embed = {
            author: aut,
            fields: [f1,f2,f11,f21,ft,s,si,f3,inv],
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
    public  static function invite(m:Message) {
        m.reply({content: "ссылка для приглашения бота: "+ bot.getInviteLink()});
    }

    @Command
    public static function g__(m:Message) {
        var glam = function(guilds:Array<Guild>, e:ErrorReport) {
            m.reply({content: Std.string(guilds.length) + ' серверов - ${stat.reqvLS} запросов в лс ${stat.reqvSV} запросов на серверах'});
        }
        bot.getGuilds({}, glam);
    }
    

    public static function news() {
        var rget = new Http("https://shikimori.one/forum/news.rss");

        rget.onData = function(data:String) {
            var xm = Parser.parse(data);
            var acc = new Access(xm.firstElement());
            var ch = acc.node.channel;
            var _guidMax = guidMax;
            for(it in ch.nodes.item) {
                var aut:EmbedAuthor = {
                    name: "Шикимори RSS",
                    icon_url: "https://sun9-8.userapi.com/c858528/v858528133/103c37/vRt_i6Mp1_k.jpg?ava=1",
                }
                var embed:Embed = {
                    title: it.node.title.innerData,
                    url: it.node.link.innerData,
                    author: aut,
                };
                var msg:MessageCreate = {
                    embed: embed,
                };

                var g = it.node.guid.innerData;
                g = StringTools.replace(g,"entry-","");
                var guid = Std.parseInt(g);

                if (_guidMax < guid) {
                    _guidMax = guid;
                }

                if (guidMax == guid) {
                    break;
                }
                var end = new Endpoints(bot);
                end.sendMessage(animeChan, msg);
            }
            guidMax = _guidMax;
        }
        rget.request();
    }

}

typedef Stat = {
    var ?reqvLS:Int;
    var ?reqvSV:Int;
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
    var chans:Array<String>;
    var ?_guidMax:Int;
}

typedef  Trapgame = {
    var ?result:Int; 
    var ?messageId:String; 
    var ?t:Timer;
}

class R34 {
    public static var blackList:Array<String> = [];
}