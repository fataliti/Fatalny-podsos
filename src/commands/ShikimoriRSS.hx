package commands;

import com.raidandfade.haxicord.types.structs.Embed;
import haxe.xml.Parser;
import haxe.xml.Access;
import haxe.Http;
import haxe.Timer;


import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.utils.DPERMS;


@desc("ShikimoriRss","Модуль автопостинга новостей с Shikimori")
class ShikimoriRss {
   
    static var shikiSubs:Array<String> = new Array();
    static var guidMax:Int = 0;

    @initialize
    public static function initialize() {


        Bot.db.request("
            CREATE TABLE IF NOT EXISTS 'shikiSub' (
                'servId' TEXT PRIMARY KEY, 
                'chanId' TEXT
            )
        ");

        var g = Bot.db.request('SELECT chanId FROM shikiSub WHERE servId = "guid"');
        if ( g.length == 0) {
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
                Bot.db.request('INSERT OR REPLACE INTO shikiSub(servId, chanId) VALUES("guid", "${guidMax}")');
            }
            rget.request();
        } else {
            guidMax = g.next().chanId;
        }

        for (row in Bot.db.request('SELECT chanId FROM shikiSub WHERE NOT servId = "guid"')) {
            shikiSubs.push(row.chanId);
        }
        
        var shikitimer = new Timer(60 * 1000 * 10);
        shikitimer.run = function() {
            if (guidMax != 0) {
                var rget = new Http("https://shikimori.one/forum/news.rss");

                var newGuid = guidMax;

                rget.onData = function(data:String) {
                    var xm = Parser.parse(data);
                    var acc = new Access(xm.firstElement());
                    var ch = acc.node.channel;
                    for(it in ch.nodes.item) {
                        var embed:Embed = {
                            title: it.node.title.innerData,
                            url: it.node.link.innerData,
                            author: {name: "Шикимори RSS",icon_url: "https://sun9-8.userapi.com/c858528/v858528133/103c37/vRt_i6Mp1_k.jpg?ava=1",},
                            color: 0xFFFFFF,
                        };

                        var g = it.node.guid.innerData;
                        g = StringTools.replace(g,"entry-","");
                        var guid = Std.parseInt(g);
                        
                        if (newGuid < guid) 
                            newGuid = guid;

                        if (guid <= guidMax) {
                            break;
                        } else {
                            for (sub in shikiSubs) {
                                Tools.sendEmbed(embed, sub);
                            }
                        }
                    }
                    guidMax = newGuid;
                    Bot.db.request('INSERT OR REPLACE INTO shikiSub(servId, chanId) VALUES("guid", "${guidMax}")');
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
        
        var g = m.getGuild().id.id;
        var exist = Bot.db.request('SELECT chanId From shikiSub chanId WHERE servId = ' + g);
        if (exist.length == 0) {
            Bot.db.request('INSERT INTO shikiSub(servId,chanId) VALUES(${g},${m.channel_id.id})');
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
        
        var g = m.getGuild().id.id;
        var exist = Bot.db.request('SELECT chanId From shikiSub chanId WHERE servId = ' + g);

        if (exist.length > 0) {
            Bot.db.request('DELETE FROM shikisub WHERE servId = ' + g);
            Tools.reply(m, "Теперь канал отписан");
        } else {
            Tools.reply(m, "Может для начала стоило подписать канал?");
        }
    }

}


typedef ShikimoriSave = {
    var ?subs:Array<String>;
    var guid:Int;
}