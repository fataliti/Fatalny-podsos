package commands;

import com.raidandfade.haxicord.types.structs.Embed;
import haxe.Http;
import haxe.Json;

import com.raidandfade.haxicord.types.Message;

class Rule34 {
    
    @command(["r","rule","r34"], "Запрос картинки от Rule34 с использованием черного листа","теги(опционально)")
    public static function r34(m:Message, words:Array<String>) {
        var find = "https://r34-json-api.herokuapp.com/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            var jlist:Array<Dynamic> = Json.parse(data); 
            var blacklist:Array<String> = BlackList.blackLists.get( m.inGuild() ? m.getGuild().id.id : m.author.id.id ); 

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
                        //Tools.sendMessage(nm, m.channel_id.id);

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
                    else {
                        if (++r < jlist.length) {
                            choose = jlist[r];
                            taglist = choose.tags;
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
    

    @command(["ra","rulea","rr", "r34a"], "Запрос картинки от Rule34 без использования черного листа","теги(опционально)")
    public static function r34a(m:Message, words:Array<String>) {
        var find = "https://r34-json-api.herokuapp.com/posts?tags=";
        for(w in words)
            find += "+" + w;
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
                    //Tools.sendMessage(nm, m.channel_id.id);  
                    
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

    @command(["rlink","rl"], "Просто сделает ссылку на пост Rule34 по Id", "Id(обязателен)")
    public static function glink(m:Message, words:Array<String>) {
        var id = words.shift();
        if (id != null) {
            Tools.reply(m, "https://rule34.xxx/index.php?page=post&s=view&id="+id);
        } else {
            Tools.reply(m, "Не указан Id");
        }
    }

}


typedef Rule34File = {
    var score:String;
    var file_url:String;
    var tags:Array<String>;
    var id:String;
    var type:String;
}