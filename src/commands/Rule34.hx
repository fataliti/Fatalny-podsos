package commands;

import com.raidandfade.haxicord.types.Channel;
import com.raidandfade.haxicord.types.structs.Embed;
import haxe.Http;
import haxe.Json;

import com.raidandfade.haxicord.types.Message;


@desc("Rule34","Модуль запросов постов от Rule34")
class Rule34 {
    
    @command(["r","rule","r34"], "Запрос картинки от Rule34 с использованием черного листа","?теги")
    public static function r34(m:Message, words:Array<String>) {
        var find = "https://r34-json-api.herokuapp.com/posts?tags="+words.join("+");
        var rget = new Http(find);
        rget.onData = function (data:String) {  
            var r = post(m.inGuild() ? m.getGuild().id.id : m.author.id.id, m.channel_id.id, data);
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

        var jlist:Array<Dynamic> = Json.parse(data); 
            var blacklist:Array<String> = BlackList.blackLists.get(servId); 

            var r = Math.ceil(Std.random(jlist.length));
            var choose:Rule34File = jlist[r];
                    
            if (choose != null) { 
                var taglist:Array<String> = choose.tags;
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
                        var nm = StringTools.replace(choose.file_url, "https://r34-json-api.herokuapp.com/images?url=","");

                        if (choose.type == "video") {
                            Tools.sendMessage('Score:${choose.score} Id:${choose.id} ${nm}', chanId);
                        } else {
                            var embed:Embed = {
                                image: {url: nm},
                                title: "Rule34",
                                url: "https://rule34.xxx/index.php?page=post&s=view&id="+choose.id,
                                author: {name: "Score: " + choose.score, icon_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcREQThzshgW7gT2yGDvszv0vWhtPH7HfAv4D9UogSp_V8CVO4O1&usqp=CAU"},
                                color: 0x3fe885,
                            }
                            Tools.sendEmbed(embed, chanId);
                        }

                    }
                    else {
                        if (++r < jlist.length) {
                            choose = jlist[r];
                            taglist = choose.tags;
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

    @command(["ra","rulea","rr", "r34a"], "Запрос картинки от Rule34 без использования черного листа","?теги")
    public static function r34a(m:Message, words:Array<String>) {
        var find = "https://r34-json-api.herokuapp.com/posts?tags="+words.join("+");

        var rget = new Http(find);
        rget.onData = function (data:String) {  
            var jlist:Array<Dynamic> = Json.parse(data); 
            var r = Math.ceil(Std.random(jlist.length));
            var choose:Rule34File = jlist[r];  
            if (choose != null) { 
                var nm = StringTools.replace(choose.file_url, "https://r34-json-api.herokuapp.com/images?url=","");
                if (m.inGuild()) {
                    Tools.sendMessage('Score:${choose.score} Id:${choose.id} ||${nm} ||', m.channel_id.id);   
                } else {   
                    if (choose.type == "video") {
                        Tools.sendMessage('Score:${choose.score} Id:${choose.id} ${nm}', m.channel_id.id);
                    } else {
                        var embed:Embed = {
                            image: {url: nm},
                            title: "Rule34",
                            url: "https://rule34.xxx/index.php?page=post&s=view&id="+choose.id,
                            author: {name: "Score: " + choose.score, icon_url: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcREQThzshgW7gT2yGDvszv0vWhtPH7HfAv4D9UogSp_V8CVO4O1&usqp=CAU"},
                            color: 0x3fe885,
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

    @command(["rlink","rl"], "Просто сделает ссылку на пост Rule34 по Id", ">Id")
    public static function glink(m:Message, words:Array<String>) {
        var id = words.shift();
        if (id != null) {
            Tools.reply(m, "https://rule34.xxx/index.php?page=post&s=view&id="+id);
        } else {
            Tools.reply(m, "Не указан Id");
        }
    }

    @command(["r34total","rt"], "Количество постов на Rule34 с указанным тегом", "?теги") 
    public static function r34total(m:Message, words:Array<String>) {
        var posts = totalPost(words);

        if (posts == '')
            m.react("⚠️");
        else 
            Tools.reply(m, 'По запросу `${words.join(" ")}` на Rule34 есть `${posts}` постов');
    }

    public static function totalPost(words:Array<String>) {
        var find = "https://rule34.xxx/index.php?page=dapi&s=post&q=index&tags=" + words.join("+");
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


}


typedef Rule34File = {
    var score:String;
    var file_url:String;
    var tags:Array<String>;
    var id:String;
    var type:String;
}