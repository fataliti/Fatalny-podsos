package commands;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.utils.DPERMS;
import haxe.Http;
import haxe.Json;
import haxe.Timer;

@desc("TimedPost","Модуль работы с автопостингом")
class TimedPost {
    
    public static var subMap:Map<String, {timer:Timer, sub:Subscribtion}> = new Map();


    @initialize
    public static function initialize() {

        Bot.db.request("
            CREATE TABLE IF NOT EXISTS 'subs' (	
                'chanId' TEXT PRIMARY KEY, 
                'servId' TEXT, 
                'tag' TEXT,
                'page' TEXT,
                'time' INTEGER DEFAULT 15,
                'type' INTEGER
            )
        ");

        var list = Bot.db.request("SELECT chanId, servId, tag, page, time, type FROM subs");

        for (s in list) { 
            var timer = new Timer(60 * 1000 * s.time);
            var _sub:Subscribtion = {
                servId: s.servId,
                chanId: s.chanId,
                page: s.page,
                tags: s.tag,
                time: s.time,
                type: s.type,
            }

            switch(s.type) {
                case 0: timer.run = function() {gPost(s.servId, s.chanId, s.tag, s.page);}
                case 1: timer.run = function() {yaPost(s.servId, s.chanId, s.tag, s.page);}
                case 2: timer.run = function() {rPost(s.servId, s.chanId, s.tag, s.page);}
            }

            subMap.set(s.chanId, {timer: timer, sub: _sub});
        }
    }


    static function gPost(servId:String, chanId:String, tags:String, page:Int) {
        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=" + tags +"&page="+ Std.string(Std.random(page));
        var rget = new Http(find);
        rget.onData = function (data:String) {  
            Gelbooru.post(servId, chanId, data);
        }

        rget.request();
    }

    @command(["subg"], "Подписать канал на автопост с Gelbooru по заданным тегам с учетом черного списка тегов", "?теги")
    public static function subg(m:Message, words:Array<String>) {
        if (!hasPermission(m)) return;

        var find = "https://gelbooru-xsd8bjco8ukx.runkit.sh/posts?tags=" + words.join("+");
        var rget = new Http(find);
        rget.onData = function (data:String) {  
            var jlist:commands.Gelbooru.GelbooruFile = Json.parse(data);
            if (jlist.total > 0) { 
                var sub:Subscribtion = {
                    servId: m.getGuild().id.id,
                    chanId:m.channel_id.id,
                    page: Math.floor(jlist.total / 100),
                    tags: words.join("+"),
                    type: 0,
                };
                
                if (jlist.total > 20000) jlist.total = 20000;
                if (sub.page > 200) sub.page = 200;
                
                var r = Bot.db.request('SELECT time FROM subs WHERE chanId = "${m.channel_id.id}"');
                var prevTime = 15;
                if (r.length > 0) {
                    prevTime = r.results().first().time;
                }
                sub.time = prevTime;
                sub.type = 0;

                var ex = subMap.get(sub.chanId);
                if (ex != null)
                    ex.timer.stop();

                var t = new Timer(1000*60*prevTime);
                t.run = function () {gPost(sub.servId,sub.chanId,sub.tags,sub.page);}
                subMap.set(sub.chanId, {timer: t, sub: sub});

                Bot.db.request('
                    INSERT OR REPLACE INTO 
                        subs(servId, chanId, tag, page, type, time) 
                        VALUES("${sub.servId}", "${sub.chanId}", "${sub.tags}", "${sub.page}", "0","${prevTime}")
                ');
                Tools.sendMessage('Автопост с Gelbooru по запросу `${words.join(" ")}` из числа `${jlist.total}` вариантов, если не учитывать черный список с интервалом в `${prevTime}` минут', m.channel_id.id);
            } else {
                Tools.sendMessage("Не обнаружено ничего что можно было бы автопостить", m.channel_id.id);
            }
        }

        rget.onError = function(error) {
            m.react("⚠️");
        }

        rget.request();
    }


    @command(["subtime"],"Интервал автопостинга",">интервал(минуты)")
    public static function subtime(m:Message, words:Array<String>) {
        if (!hasPermission(m)) return;

        var t = Std.parseInt(words.shift());
        if (t == null) {
            Tools.reply(m, "Не указано время");
            return;
        }
        
        if (t < 1) {
            t = 1;
        }

        var exist = subMap.get(m.channel_id.id);
        if (exist == null) {
            Tools.reply(m, "Для начала нужно подписать канал");
            return;
        }

        Bot.db.request('UPDATE subs SET time = ${t} WHERE chanId = "${m.channel_id.id}"');
        Tools.reply(m, 'Новый пост каждые `${t}` минут');

        exist.timer.stop();
        exist.timer = new Timer(60 * 1000 * t);

        switch(exist.sub.type) {
            case 0: exist.timer.run = function () {gPost(exist.sub.chanId, exist.sub.servId, exist.sub.tags, exist.sub.page);}
            case 1: exist.timer.run = function () {yaPost(exist.sub.chanId, exist.sub.servId, exist.sub.tags, exist.sub.page);}
            case 2: exist.timer.run = function () {yaPost(exist.sub.chanId, exist.sub.servId, exist.sub.tags, exist.sub.page);}
        }
        exist.sub.time = t;
    }

    @command(["unsub"], "Отписать канал от автопостинга")
    public static function unsub(m:Message) {
        if (!hasPermission(m)) return;

        var get = subMap.get(m.channel_id.id);
        if (get != null) {
            get.timer.stop();
            Bot.db.request('DELETE FROM subs WHERE chanId = "${m.channel_id.id}"');
            subMap.remove(m.channel_id.id);
            Tools.sendMessage("Канала отписан от рассылки", m.channel_id.id);
        }
    }

    @command(["subinfo"], "Посмотреть что может запоститься в автопосте")
    public static function subInfo(m:Message) {
        if (!m.inGuild()) {
            Tools.reply(m, "Не работает в лс");
            return;
        }

        var sub = subMap.get(m.channel_id.id);

        if (sub != null) {
            var t = StringTools.replace(sub.sub.tags, "+", " ");
            if (t.length == 0) {
                t == "НИКАКИЕ";
            }

            Tools.sendMessage('канал подписан на теги `${t}` и есть менее `${sub.sub.page * 100}` того что может запоститься каждые `${sub.sub.time}` минут', m.channel_id.id);
        } else {
            Tools.sendMessage("канал ни на что не подписан", m.channel_id.id);
        }
    }

    @command(["subya"], "Подписать канал на автопост c Yandere по заданным тегам с учетом черного списка тегов", "?теги")
    public static function subya(m:Message, words:Array<String>) {
        if (!hasPermission(m)) return;
        var posts = Yandere.totalPost(words);

        if (posts == '') {
            m.react("⚠️");
            return;
        } else {
            var sub:Subscribtion = {
                servId: m.getGuild().id.id,
                chanId:m.channel_id.id,
                page: Math.floor(Std.parseInt(posts) / 100),
                tags: words.join("+"),
                type: 1,
            };
            var r = Bot.db.request('SELECT time FROM subs WHERE chanId = "${m.channel_id.id}"');
            var prevTime = 15;
            if (r.length > 0) {
                prevTime = r.results().first().time;
            }
            sub.time = prevTime;

            var ex = subMap.get(sub.chanId);
            if (ex != null)
                ex.timer.stop();

            var t = new Timer(1000*60*prevTime);
            t.run = function () {yaPost(sub.servId,sub.chanId,sub.tags,sub.page);}
            subMap.set(sub.chanId, {timer: t, sub: sub});
            Bot.db.request('
                INSERT OR REPLACE INTO 
                    subs(servId, chanId, tag, page, type, time) 
                    VALUES("${sub.servId}", "${sub.chanId}", "${sub.tags}", "${sub.page}", "1","${prevTime}")
            ');
            Tools.sendMessage('Автопост c Yandere по запросу `${words.join(" ")}` из числа `${posts}` вариантов, если не учитывать черный список с интервалом в `${prevTime}` минут', m.channel_id.id);
        }
    }

    static function yaPost(servId:String, chanId:String, tags:String, page:Int) {
        var find = "https://yande.re/post.json?api_version=2&tags=" + tags + "&page="+ Std.string(Std.random(page));
        var rget = new Http(find);
        rget.onData = function (data:String) {  
            Yandere.post(servId, chanId, data);
        }
        rget.request();
    }


    @command(["subr"], "Подписать канал на автопост c Rule34 по заданным тегам с учетом черного списка тегов", "?теги")
    public static function subr(m:Message, words:Array<String>) {
    
        if (!hasPermission(m)) return;
        var posts = Rule34.totalPost(words);

        if (posts == '') {
            m.react("⚠️");
            return;
        } else {
            var sub:Subscribtion = {
                servId: m.getGuild().id.id,
                chanId:m.channel_id.id,
                page: Math.floor(Std.parseInt(posts) / 100),
                tags: words.join("+"),
                type: 2,
            };
            var r = Bot.db.request('SELECT time FROM subs WHERE chanId = "${m.channel_id.id}"');
            var prevTime = 15;
            if (r.length > 0) {
                prevTime = r.results().first().time;
            }
            sub.time = prevTime;

            var ex = subMap.get(sub.chanId);
            if (ex != null)
                ex.timer.stop();

            var t = new Timer(1000*60*prevTime);
            t.run = function () {rPost(sub.servId,sub.chanId,sub.tags,sub.page);}
            subMap.set(sub.chanId, {timer: t, sub: sub});

            Bot.db.request('
                INSERT OR REPLACE INTO 
                    subs(servId, chanId, tag, page, type, time) 
                    VALUES("${sub.servId}", "${sub.chanId}", "${sub.tags}", "${sub.page}", "2","${prevTime}")
            ');
            Tools.sendMessage('Автопост c Rule34 по запросу `${words.join(" ")}` из числа `${posts}` вариантов, если не учитывать черный список с интервалом в `${prevTime}` минут', m.channel_id.id);
        }
    }


    static function rPost(servId:String, chanId:String, tags:String, page:Int) {
        var find = "https://r34-json-api.herokuapp.com/posts?tags="+tags+"&page="+ Std.string(Std.random(page));
        var rget = new Http(find);
        rget.onData = function (data:String) {  
            Rule34.post(servId, chanId, data);
        }
        rget.request();
    }

    static function hasPermission(m:Message):Bool {
        if (!m.inGuild()) {
            Tools.reply(m, "Не работает в лс");
            return false;
        }
        if (!m.hasPermission(DPERMS.MANAGE_CHANNELS)) {
            Tools.reply(m, "Нужно право управлять каналами");
            return false;
        }
        return true;
    }

}

typedef Subscribtion = {
    var servId:String;
    var chanId:String;
    var tags:String;
    var page:Int;
    var ?type:Int;
    var ?time:Int;
}