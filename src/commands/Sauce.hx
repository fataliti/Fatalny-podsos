package commands;

import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.structs.Emoji;
import com.raidandfade.haxicord.endpoints.Endpoints;
import com.raidandfade.haxicord.types.structs.Embed;

import haxe.Timer;
import haxe.Json;
import haxe.Http;


@desc("SauceNao","Модуль поиска сурса изображений")
class SauceNao {
    static var apiKey:String = "763b68a3dcafc8a6a2b22d92db2d5bf9586cdd62";
    static var sauceMap:Map<String, {var ?num:Int; var ?src:SauceFile;}> = new Map();

    @command(["sauce", "s"], "Найти сурс изображения по ссылке", ">ссылка")
    public static function sauce(m:Message, words:Array<String>) {

        var pic = words.shift();
        if (pic == null) {
            Tools.reply(m, "кажется ты не дал мне ссылку на картинку");
            return;
        }
        var i = pic.indexOf("?");
        if (i!=-1) {
            pic = pic.substr(0, i);
        }
        var url = "https://saucenao.com/search.php?api_key="+apiKey+"&db=999&output_type=2&testmode=1&numres=10&url="+pic;
        var rget = new Http(url);

        rget.onData = function (data:String) {
            var s:SauceFile = Json.parse(data);

            if (s.results == null) {
                Tools.reply(m, "Ничего не найдено, наверное ты сунул видео, а оно не обработается, или файл жирный или еще чего...");
                return;
            }

            var embed:Embed = {title: "подготовка"}

            var cb = function (msg:Message, e:ErrorReport) {
                m.delete();

                msg.react("⬅️");
                msg.react("➡️");
                sauceMap.set(msg.id.id, {src: s, num: 0});

                update(msg, {src: s, num: 0});

                var timer = new Timer(1000*60*2);
                timer.run = function () {
                    sauceMap.remove(msg.id.id);
                    timer.stop();
                }
            }

            m.reply({embed: embed}, cb);
        }

        rget.onError = function(error) {
            m.react("⚠️");
        }

        rget.request();
    }

    static function update(m:Message, s:{num:Int, src:SauceFile}) {

        var thumb = s.src.results[s.num].header.thumbnail;
        thumb = StringTools.replace(thumb, " ", "%20");

        var embed:Embed = {
            color: 0xFFFFFF,
            author: {name: 'схожесть ${s.src.results[s.num].header.similarity}%', icon_url: "https://progsoft.net/images/saucenao-icon-f72ab77d27f7758915fa2cd07e63da21b3838808.png"},
            thumbnail: {url: thumb,},
            fields: [],
            footer: {text: '${s.num+1}/${s.src.results.length}'}
        }
        
        if (s.src.results[s.num].data.source != null && s.src.results[s.num].data.source != "" ) {embed.fields.push({name: "source", value: s.src.results[s.num].data.source,});}
        if (s.src.results[s.num].data.title != null && s.src.results[s.num].data.title != "")  {embed.fields.push({name: "title",value: s.src.results[s.num].data.title,});}
        if (s.src.results[s.num].data.characters != null && s.src.results[s.num].data.characters != "")  {embed.fields.push({name: "chracters",value: s.src.results[s.num].data.characters,});}
        if (s.src.results[s.num].data.material != null && s.src.results[s.num].data.material !="")  {embed.fields.push({name: "material",value: s.src.results[s.num].data.material,});}
        if (s.src.results[s.num].data.ext_urls != null) {embed.fields.push({name: "links",value: s.src.results[s.num].data.ext_urls.join(" "),});}

        m.edit({embed: embed});
    }

    @reactionAdd
    public static function reactionAdd(m:Message, u:User, e:Emoji) {
        if (u.bot)
            return;

        if (sauceMap.exists(m.id.id)) {
            if (e.name == "⬅️" || e.name == "➡️") {

                var s = sauceMap.get(m.id.id);
                if (e.name == "⬅️")
                    s.num--;
                if (e.name == "➡️")
                    s.num++;

                if (s.num < 0)
                    s.num = s.src.results.length-1;
                if (s.num >= s.src.results.length)
                    s.num = 0;
                
                update(m, s);
            }
        }
    }

    @reactionDel
    public static function reactionDel(m:Message, u:User, e:Emoji) {
        reactionAdd(m, u, e);
    }
}


typedef SauceFile = {
    var ?header:{};

    var ?results:Array<{ 
        var ?header:{
            var ?similarity:String; 
            var ?thumbnail:String; 
        }; 
        var ?data:{
            var ?ext_urls:Array<String>; 
            var ?title:String; 
            var ?source:String; 
            var ?characters:String; 
            var ?material:String;
        } 
    }>;
}

