package commands;

import haxe.Timer;
import haxe.Http;
import haxe.Json;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.structs.Emoji;
import com.raidandfade.haxicord.endpoints.Endpoints.ErrorReport;

class TrapGame {

    static var trapGames:Map<String,TrapgameType> = new Map();
    static var strics:Map<String,Int> = new Map();

    @command(["play","trap"], "Игра в которой вам нужно угадать мальчик перед вами или девочка")
    public static function trap(m:Message) {
        if (!trapGames.exists(m.author.id.id)) {
            var tg:TrapgameType = {};
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
                    var jlist:Gelbooru.GelbooruFile = Json.parse(data); 
                    var r = Math.ceil(Std.random(jlist.count));
                    var choose = jlist.posts[r];
                            
                    if (choose != null) { 
                        gm.edit({embed: {image: {url: choose.file_url} ,author: {icon_url: m.author.avatarUrl, name: m.author.username }}});
                        gm.react("♂️");
                        gm.react("♀️");
                                
                        var timer = new Timer(1000*30);
                        tg.t = timer;
                        
                        tg.id = choose.id;

                        timer.run = function() {
                            gm.edit({embed:{title: "время вышло", author: {icon_url: m.author.avatarUrl, name: m.author.username }, url: "https://gelbooru.com/index.php?page=post&s=view&id="+tg.id}});
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

    static var strikMsg = [
        "Угадал!",
        "Двойное угадывание!",
        "Тройное угадывание!",
        "Безумие!",
        "Доминирование!",
        "Мегаугадывание",
        "Неудержимый",
        "Полный улет",
        "Чудовищное угадывание!",
        "Божественно!",
        "Более чем божественно!",
        "ПРЕВОСХОДИТ ВСЕХ БОГОВ!!!",
    ];


    static function update(u:User, m:Message, tg:TrapgameType) {
        var mn = strics[u.id.id];
        if (mn == null) {
            mn = 0;
            strics[u.id.id] = 0;
        }
        if (mn >= strikMsg.length)
            mn = strikMsg.length-1;

        var txt = strikMsg[ mn];
        m.edit({embed: {title: "ВЕРНО!", author: {icon_url: u.avatarUrl, name: u.username }, url: "https://gelbooru.com/index.php?page=post&s=view&id="+tg.id, footer: {text: txt}}});
    
        strics[u.id.id]++;
    }

    @reactionAdd
    public static function reactionAdd(m:Message, u:User, e:Emoji) {
        if (trapGames.exists(u.id.id)) {
            var tg = trapGames.get(u.id.id);
            if (tg.messageId == m.id.id) {
                if (e.name == "♂️" || e.name == "♀️") {
                    if (e.name == "♀️" && tg.result == 0) {
                        update(u, m, tg);
                    } else if (e.name == "♂️" && tg.result == 1) {
                        update(u, m, tg);
                    } else {

                        var txt;
                        if (strics[u.id.id] == null || strics[u.id.id] == 0) {
                            txt = "ни разу не угадал";
                        } else {
                            txt = 'серия из ${strics[u.id.id]} угадываний была первана';
                            strics.set(u.id.id, 0);
                        }


                        m.edit({embed: {title: "НЕТ!", author: {icon_url: u.avatarUrl, name: u.username }, url: "https://gelbooru.com/index.php?page=post&s=view&id="+tg.id, footer: {text: txt}}});
                    
                    }
                    tg.t.stop();
                    trapGames.remove(u.id.id);
                }
            }
        }
    }

}

typedef  TrapgameType = {
    var ?result:Int; 
    var ?messageId:String; 
    var ?t:Timer;
    var ?id:String;
}