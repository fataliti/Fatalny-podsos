package commands;

import com.raidandfade.haxicord.types.structs.Embed;
import sys.FileSystem;
import sys.io.File;
import haxe.xml.Parser;
import haxe.xml.Access;
import haxe.Json;
import haxe.Http;
import haxe.Timer;


import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.utils.DPERMS;

class ShikimoriRss {
   
    static var shikiSubs:Array<String> = new Array();
    static var guidMax:Int = 0;

    @initialize
    public static function initialize() {

        if (FileSystem.exists("ShikimoriSave.txt")) {
            var load:ShikimoriSave = Json.parse(File.getContent("ShikimoriSave.txt"));
            guidMax = load.guid;
            shikiSubs = load.subs;
        } 

        if (guidMax == 0) {
            var rget = new Http("https://shikimori.one/forum/news.rss");
            rget.onData = function(data:String) {
                var xm = Parser.parse(data);
                var acc = new Access(xm.firstElement());
                var ch = acc.node.channel;
                var g = ch.node.item.node.guid.innerData;
                g = StringTools.replace(g,"entry-","");
                var guid = Std.parseInt(g);
                guidMax = guid; 
                trace("new shikimori guid get " + guidMax);
            }
            rget.request();
        }

        var shikitimer = new Timer(60 * 1000 * 10);
        shikitimer.run = function() {
            if (guidMax != 0) {
                var rget = new Http("https://shikimori.one/forum/news.rss");

                rget.onData = function(data:String) {
                    var xm = Parser.parse(data);
                    var acc = new Access(xm.firstElement());
                    var ch = acc.node.channel;
                    for(it in ch.nodes.item) {
                        var embed:Embed = {
                            title: it.node.title.innerData,
                            url: it.node.link.innerData,
                            author: {name: "Шикимори RSS",icon_url: "https://sun9-8.userapi.com/c858528/v858528133/103c37/vRt_i6Mp1_k.jpg?ava=1",},
                        };

                        var g = it.node.guid.innerData;
                        g = StringTools.replace(g,"entry-","");
                        var guid = Std.parseInt(g);

                        if (guid <= guidMax) {
                            guidMax = guid;
                            break;
                        }

                        for (sub in shikiSubs) {
                            Tools.sendEmbed(embed, sub);
                        }
                        
                    }
                }
                rget.request();
            }
        }

    }

    @command(["shikiSub"], "Подписать канал на рассылку новостей с Shikimori")
    public static function shikiSub(m:Message) {
        if (!m.inGuild()) {
            Tools.reply(m, "Не работает в лс");
            return;
        }
        if (!m.hasPermission(DPERMS.MANAGE_CHANNELS)) {
            Tools.reply(m, "Нужно право управлять каналами");
            return;
        }

        if (shikiSubs.indexOf(m.channel_id.id) == -1) {
            shikiSubs.push(m.channel_id.id);
            Tools.reply(m, "Теперь канал подписан");
        } else {
            Tools.reply(m, "Канал уже подписан");
        }

    }

    @command(["shikiUnsub"], "Отписаться от рассылки")
    public static function shikiUnsub(m:Message) {
        if (!m.inGuild()) {
            Tools.reply(m, "Не работает в лс");
            return;
        }
        if (!m.hasPermission(DPERMS.MANAGE_CHANNELS)) {
            Tools.reply(m, "Нужно право управлять каналами");
            return;
        }

        if (shikiSubs.remove(m.channel_id.id)) {
            Tools.reply(m, "Теперь канал отписан");
        } else {
            Tools.reply(m, "Может для начала стоило подписать канал?");
        }

    }

    @down
    public static function down() {
        var shikimoriSave:ShikimoriSave = {
            subs: shikiSubs,
            guid: guidMax,
        }
        File.saveContent("ShikimoriSave.txt", Json.stringify(shikimoriSave));
    }

}


typedef ShikimoriSave = {
    var ?subs:Array<String>;
    var guid:Int;
}