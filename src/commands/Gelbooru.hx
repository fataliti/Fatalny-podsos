package commands;

import com.raidandfade.haxicord.types.Message;
import haxe.Http;
import haxe.Json;

class Gelbooru {

    @command(["g", "gelbooru"], "Запрос картинки от Gelbooru с использованием черного листа")
    public static function g(m:Message, words:Array<String>) {
        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            var jlist:GelbooruFile = Json.parse(data); 
            var blacklist = BlackList.blackLists.get(m.getGuild().id.id); 

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
                        Tools.sendMessage(choose.file_url, m.channel_id.id);
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

    @command(["gа", "gelboorua", "gg"], "Запрос картинки от Gelbooru без использования черного листа")
    public static function ga(m:Message, words:Array<String>) {
        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            var jlist:GelbooruFile = Json.parse(data); 
            var r = Math.ceil(Std.random(jlist.count));
            var choose = jlist.posts[r];
                    
            if (choose != null) { 
                if (m.inGuild())
                    Tools.sendMessage("||"+choose.file_url+" ||", m.channel_id.id);
                else 
                    Tools.sendMessage(choose.file_url, m.channel_id.id);
            } else {
                Tools.sendMessage("ничего не нашел", m.channel_id.id);
            }
        }

        rget.onError = function(error) {
            m.react("⚠️");
        }

        rget.request();
    }


}

typedef GelbooruFile = {
    var total:Int;
    var count:Int;
    var page:Int;
    var posts:Array<{score:String, file_url:String, rating:String, tags:String, id:String}>;
}