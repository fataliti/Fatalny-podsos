package commands;

import com.raidandfade.haxicord.endpoints.Endpoints;
import com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate;
import com.raidandfade.haxicord.types.structs.Embed;
import com.raidandfade.haxicord.types.Message;
import haxe.Http;
import haxe.Json;

class Gelbooru {

    @command(["gelbooru", "g"], "Запрос картинки от Gelbooru с использованием черного листа", "теги(опционально)")
    public static function gelbooru(m:Message, words:Array<String>) {
        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            var jlist:GelbooruFile = Json.parse(data); 
            var blacklist = BlackList.blackLists.get( m.inGuild() ? m.getGuild().id.id : m.author.id.id ); 

            var r = Math.ceil(Std.random(jlist.count));
            var choose = jlist.posts[r];
                    
            if (choose != null) { 
                var taglist:Array<String> = choose.tags.split(" ");
                    
                var finding = true;
                while (finding == true)  {
                    var fail = false;

                    if (blacklist != null) { 
                        for (tag in taglist)
                        {   
                            var result:Int = blacklist.indexOf(tag);
                            if (result >= 0) {
                                fail = true;
                                break;
                            }
                        } 
                    }

                    if (!fail) {
                        finding = false;

                        if (StringTools.endsWith(choose.file_url,".webm")) {
                            Tools.sendMessage('Score:${choose.score} Id:${choose.id} ${choose.file_url}', m.channel_id.id);
                        } else {
                            var embed:Embed = {
                                image: {url: choose.file_url},
                                title: "Gelbooru",
                                url: "https://gelbooru.com/index.php?page=post&s=view&id="+choose.id,
                                author: {name: "Score: " + choose.score, icon_url: "https://pbs.twimg.com/profile_images/1118350008003301381/3gG6lQMl.png"},
                                color: 0x3333FF,
                            }
                            Tools.sendEmbed(embed, m.channel_id.id);
                        }

                    }
                    else {
                        if (++r < jlist.count) {
                            choose = jlist.posts[r];
                            taglist = choose.tags.split(" ");
                        } else {
                            finding = false;
                            Tools.sendMessage("мне нельзя такое показывать", m.channel_id.id);
                        }
                    }
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

    @command(["gelboorua", "gg", "gа"], "Запрос картинки от Gelbooru без использования черного листа", "теги(опционально)")
    public static function gelbooruAll(m:Message, words:Array<String>) {
        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            var jlist:GelbooruFile = Json.parse(data); 
            var r = Math.ceil(Std.random(jlist.count));
            var choose = jlist.posts[r];
                    
            if (choose != null) { 
                if (m.inGuild()) {
                    Tools.sendMessage('Score:${choose.score} Id:${choose.id} ||${choose.file_url} ||', m.channel_id.id);
                } else {  
                    if (StringTools.endsWith(choose.file_url,".webm")) {
                        Tools.sendMessage('Score:${choose.score} Id:${choose.id} ${choose.file_url}', m.channel_id.id);
                    } else {
                        var embed:Embed = {
                            image: {url: choose.file_url},
                            title: "Gelbooru",
                            url: "https://gelbooru.com/index.php?page=post&s=view&id="+choose.id,
                            author: {name: "Score: " + choose.score, icon_url: "https://pbs.twimg.com/profile_images/1118350008003301381/3gG6lQMl.png"},
                            color: 0x3333FF,
                        }
                        Tools.sendEmbed(embed, m.channel_id.id);
                    }
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

    @command(["gelbooruTotal", "gt"], "Количество постов на Gelbooru с указанными тегами", "теги(опционально)")
    public static function gelbooruTotal(m:Message, words:Array<String>) {
        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  
            var jlist:GelbooruFile = Json.parse(data); 
            Tools.reply(m, 'По запросу **${words}** на Gelbooru есть **${jlist.total}** постов');
        }

        rget.onError = function(error) {
            m.react("⚠️");
        }

        rget.request();
    }

    @command(["glink","gl"], "Просто сделает ссылку на пост Gelbooru по Id", "Id(обязателен)")
    public static function glink(m:Message, words:Array<String>) {
        var id = words.shift();
        if (id != null) {
            Tools.reply(m, "https://gelbooru.com/index.php?page=post&s=view&id="+id);
        } else {
            Tools.reply(m, "Не указан Id");
        }
    }

}

typedef GelbooruFile = {
    var total:Int;
    var count:Int;
    var page:Int;
    var posts:Array<{score:String, file_url:String, rating:String, tags:String, id:String}>;
}