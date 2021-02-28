package commands;

import com.raidandfade.haxicord.types.structs.Embed;
import haxe.Json;
import haxe.xml.Access;
import haxe.Http;
import com.raidandfade.haxicord.types.Message;

@desc("Yandere","Модуль запросов постов от Yandere")
class Yandere {
    
    
    @command(["yy"], "Запрос от Yande.re без учета блеклиста", "?теги")
    public static function yy(m:Message, words:Array<String>) {
        var find = "https://yande.re/post.json?api_version=2&tags=" + words.join("+");
        var rget = new Http(find);
        
        rget.onData = function (data) {
            var posts:YandereFile = Json.parse(data);
            var r = Math.ceil(Std.random(posts.posts.length));
            var choose = posts.posts[r];

            if (choose != null) {
                if (m.inGuild()) {
                    Tools.sendMessage('Score:${choose.score} Id:${choose.id} ||${choose.sample_url} ||', m.channel_id.id);
                } else {
                    sendPost(choose, m.channel_id.id);
                }
            } else {
                Tools.sendMessage("ничего не нашел", m.channel_id.id);
            }
        }
        rget.onError = function(error) {
            m.react("⚠️");
        }
        rget.request();
    }

    @command(["ya", "y"], "Запрос от Yande.re с учетом блеклиста", "?теги")
    public static function ya(m:Message, words:Array<String>)  {
        var find = "https://yande.re/post.json?api_version=2&tags=" + words.join("+");
        var rget = new Http(find);
        rget.onData = function (data) {
           var r = post(m.getGuild().id.id, m.channel_id.id, data);
           switch(r) {
                case 1: Tools.sendMessage("мне нельзя такое показывать", m.channel_id.id);
                case 2: Tools.sendMessage("ничего не нашел", m.channel_id.id);
            }
        }
        rget.onError = function(error) {
            m.react("⚠️");
        }
        rget.request();
    }


    public static function post(servId:String, chanId:String, data:String):Int { 
        var blacklist = BlackList.blackLists.get(servId); 
        var posts:YandereFile = Json.parse(data);
        var r = Math.ceil(Std.random(posts.posts.length));
        var choose = posts.posts[r];


        if (choose != null) { 
            var taglist:Array<String> = choose.tags.split(" ");
                
            var finding = true;
            while (finding == true)  {
                var fail = false;

                if (blacklist != null) { 
                    for (tag in taglist) {   
                        var result:Int = blacklist.indexOf(tag);
                        if (result >= 0) {
                            fail = true;
                            break;
                        }
                    } 
                }

                if (!fail) {
                    finding = false;
                    sendPost(choose, chanId);
                }
                else {
                    if (++r < posts.posts.length) {
                        choose = posts.posts[r];
                        taglist = choose.tags.split(" ");
                    } else {
                        finding = false;
                        return 1;
                    }
                }
            }         
        } else {
            return 2;
        }
        return 0;
    }


    @command(["yandereTotal", "yt"], "Количество постов на Yandere с указанными тегами", "?теги")
    public static function gelbooruTotal(m:Message, words:Array<String>) {
        var posts = totalPost(words);

        if (posts == '')
            m.react("⚠️");
        else 
            Tools.reply(m, 'По запросу `${words.join(" ")}` на Yandere есть `${posts}` постов');
    }

    public static function totalPost(words:Array<String>) {
        var find = "https://yande.re/post.xml?tags=" + words.join("+");
        var rget = new Http(find);

        var posts = '';
        rget.onData = function (data:String) {  
            var xml = Xml.parse(data).firstElement();
            posts = xml.get("count");
        }
        rget.onError = function(error) {
            posts = '';
        }
        rget.request();
        return posts;
    }

    static function sendPost(choose:{id:Int, score:Int, sample_url:String, tags:String}, chanId:String) {
        var embed:Embed = {
            image: {url: choose.sample_url},
            title: "Yande.re",
            url: "https://yande.re/post/show/"+choose.id,
            author: {name: "Score: " + choose.score, icon_url: "https://media.discordapp.net/attachments/713805577331015820/741582208577568838/favicon.png?width=14&height=14"},
            color: 0xee8887,
        }
        Tools.sendEmbed(embed, chanId);
    }

    @command(["yal"], "Просто сделает ссылку на пост Yandere по Id", ">Id")
    public static function glink(m:Message, words:Array<String>) {
        var id = words.shift();
        if (id != null) {
            Tools.reply(m, "https://yande.re/post/show/"+id);
        } else {
            Tools.reply(m, "Не указан Id");
        }
    }

}

typedef YandereFile = {
    var posts:Array<{
        var id:Int;
        var score:Int;
        var sample_url:String;
        var tags:String;
    }>;
}