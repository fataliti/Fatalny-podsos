package commands;

import haxe.Http;
import haxe.Json;

import com.raidandfade.haxicord.types.Message;

class Rule34 {
    
    @command(["r","rule","r34"], "Запрос картинки от Rule34 с использованием черного листа")
    public static function r(m:Message, words:Array<String>) {
        var find = "https://r34-json-api.herokuapp.com/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);
        rget.onData = function (data:String) {  

            var jlist:Array<Dynamic> = Json.parse(data); 
            var blacklist:Array<String> = BlackList.blackLists.get(m.getGuild().id.id); 

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
                        Tools.sendMessage(nm, m.channel_id.id);
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
    

    @command(["ra","rulea","rr", "r34a"], "Запрос картинки от Rule34 без использования черного листа")
    public static function ra(m:Message, words:Array<String>) {
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
                if (m.inGuild())
                    Tools.sendMessage('||$nm ||', m.channel_id.id);   
                else 
                    Tools.sendMessage(nm, m.channel_id.id);  
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


typedef Rule34File = {
    var score:String;
    var file_url:String;
    var tags:Array<String>;
}