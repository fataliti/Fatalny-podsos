package commands;

import com.raidandfade.haxicord.types.structs.Embed;
import commands.Gelbooru.GelbooruFile;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.utils.DPERMS;

import sys.FileSystem;
import sys.io.File;
import haxe.Http;
import haxe.Json;
import haxe.Timer;


class TimedPost {
    
    public static var subList:Array<Subscribtion> = new Array();

    @initialize
    public static function initialize() {
        if (FileSystem.exists("subList.txt")) {
            subList = Json.parse(File.getContent("subList.txt"));
        }
        var timer = new Timer(60 * 1000 * 15);
        timer.run = function() {
            
            for(sub in subList) {

                var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags="+sub.tags.join("+")+"&page="+Std.string(Std.random(sub.page));
                var rget = new Http(find);
                
                rget.onData = function (data:String) {  
                    var jlist:GelbooruFile = Json.parse(data); 
                    var blacklist:Array<String> = BlackList.blackLists.get(sub.servId);

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
                                    Tools.sendMessage('Score:${choose.score} Id:${choose.id} ${choose.file_url}', sub.chanId);
                                } else {
                                    var embed:Embed = {
                                        image: {url: choose.file_url},
                                        title: "Gelbooru",
                                        url: "https://gelbooru.com/index.php?page=post&s=view&id="+choose.id,
                                        author: {name: "Score: " + choose.score, icon_url: "https://pbs.twimg.com/profile_images/1118350008003301381/3gG6lQMl.png"},
                                        color: 0x3333FF,
                                    }
                                    Tools.sendEmbed(embed, sub.chanId);
                                }

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
            
        }
    }

    @command(["sub"], "Подписать канал на автопост по заданным тегам с учетом черного списка тегов", "теги(опционально) иначе самые нвые среди 20000 постов")
    public static function sub(m:Message, words:Array<String>) {
        if (!m.inGuild()) {
            Tools.reply(m, "Не работает в лс");
            return;
        }

        if (!m.hasPermission(DPERMS.MANAGE_CHANNELS)) {
            Tools.reply(m, "Нужно право управлять каналами");
            return;
        }


        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=";
        for(w in words)
            find += "+" + w;

        var rget = new Http(find);

        rget.onData = function (data:String) {  
            var jlist:commands.Gelbooru.GelbooruFile = Json.parse(data);
            if (jlist.total > 0) {
                
                var filter = subList.filter((s) -> s.chanId == m.channel_id.id)[0];
                if (filter != null) 
                    subList.remove(filter);
                
                var sub:Subscribtion = {
                    servId: m.getGuild().id.id,
                    chanId:m.channel_id.id,
                    page: Math.floor(jlist.total / 100),
                    tags: words,
                };

                if (jlist.total > 20000) jlist.total = 20000;
                if (sub.page > 200) sub.page = 200;

                Tools.sendMessage('Автопост по запросу **${words}** из числа **${jlist.total}** вариантов, если не учитывать черный список', m.channel_id.id);
                subList.push(sub);
            } else {
                Tools.sendMessage("Не обнаружено ничего что можно было бы автопостить", m.channel_id.id);
            }
        }

        rget.onError = function(error) {
            m.react("⚠️");
        }

        rget.request();
    }

    @command(["unsub"], "Отписать канал от автопостинга")
    public static function unsub(m:Message) {
        if (!m.inGuild()) {
            Tools.reply(m, "Не работает в лс");
            return;
        }

        if (!m.hasPermission(DPERMS.MANAGE_CHANNELS)) {
            Tools.reply(m, "Нужно право управлять каналами");
            return;
        }

        var filter = subList.filter((s) -> s.chanId == m.channel_id.id)[0];
        if (filter != null) {
            subList.remove(filter);
            Tools.sendMessage("Канала отписан от рассылки", m.channel_id.id);
        }
    }

    @command(["subinfo"], "Посмотреть что может запоститься в автопосте")
    public static function subInfo(m:Message) {
        if (!m.inGuild()) {
            Tools.reply(m, "Не работает в лс");
            return;
        }

        var filter = subList.filter((s) -> s.chanId == m.channel_id.id)[0];
        if (filter != null) {
            Tools.sendMessage('канал подписан на теги **${filter.tags}** и есть менее **${(filter.page)*100}** вариантов того что запостится', m.channel_id.id);
        } else {
            Tools.sendMessage("канал ни на что не подписан", m.channel_id.id);
        }
    }

    @down
    public static function down() {
        File.saveContent("subList.txt", Json.stringify(subList));
    }

}

typedef Subscribtion = {
    var servId:String;
    var chanId:String;
    var tags:Array<String>;
    var page:Int;
}