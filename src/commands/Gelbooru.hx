package commands;

import com.raidandfade.haxicord.types.Message;
import haxe.Http;
import haxe.Json;

class Gelbooru {

    @command(["гелбору","г","g"], "Запрос картинки от Gelbooru с использованием черного листа")
    public static function g() {
        
    }

    @command(["гелборуа","га","gа", "gelboorua"], "Запрос картинки от Gelbooru без использования черного листа")
    public static function ga(m:Message, words:Array<String>) {

        trace("im called");

        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            trace("rget answered");

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



        rget.request();
    }


}

typedef GelbooruFile = {
    var total:Int;
    var count:Int;
    var page:Int;
    var posts:Array<{score:String, file_url:String, rating:String, tags:String, id:String}>;
}