package commands;

import sys.FileSystem;
import haxe.Json;
import sys.io.File;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.endpoints.Endpoints.ErrorReport;

class Statistic {
    public static var statCommon:StatCommon = {};
    public static var statCommand:Array<StatCommand> = new Array();
    public static var statServers:Array<StatServers> = new Array();

    @initialize
    public static function initialize() {
        if (FileSystem.exists("statSave.txt")) {
            var statSave:StatSave = Json.parse(File.getContent("statSave.txt"));
            statCommon = statSave.statCommom;
            statCommand = statSave.statCommand;
            statServers = statSave.statServers;
        }
    }

    @command(["stat"],"Краткая статистика использования бота")
    public static function stat(m:Message) {
        var glam = function(guilds:Array<Guild>, e:ErrorReport) {
            m.reply({content: Std.string(guilds.length) + ' серверов - ${statCommon.reqvDm} запросов в лс, ${statCommon.reqvSm} запросов на серверах'});
        }
        Bot.bot.getGuilds({}, glam);
    }

    @command(["statCommand","statC"],"Статистика вызова команд")
    public static function statCom(m:Message) {
        statCommand.sort(function (a,b) return b.reqv - a.reqv);
        var top = statCommand.slice(0, 6);

        var str:String = "";
        for(t in top) {
            str += '${t.name}: ${t.reqv}\n';
        }

        Tools.sendMessage(str, m.channel_id.id);
    }

    /*
    @command(["statServer","statS"],"Топ 3 сервера вызывающих бота")
    public static function statServer(m:Message) {
        statServers.sort(function (a,b) return b.reqv - a.reqv);
        var top = statServers.slice(0, 3);
        var cb = function(guilds:Array<Guild>, error:ErrorReport)  {
            var str:String = "";
            for(t in top) {
                var g = guilds.filter((i) -> i.id.id == t.servId)[0];
                str += '${g.name}: ${t.reqv}\n';
            }

            Tools.sendMessage(str, m.channel_id.id);
        }
        Bot.bot.getGuilds({}, cb);
    }
    */
    
    @command(["statLocal","statL"],"Сколько было выполнено комманд на этом сервере")
    public static function statLocal(m:Message) {
        if (!m.inGuild())
            return;

        var serverStat = statServers.filter((s) -> s.servId == m.getGuild().id.id)[0];
        if (serverStat != null ) 
            Tools.sendMessage('На этом сервере бот был вызван **${serverStat.reqv}** раз', m.getChannel().id.id);
    }

    @command(["statFull","statF"],"Показ всей статистики сразу")
    public static function statFull(m:Message) {
        stat(m);
        statCom(m);
        //statServer(m);
        statLocal(m);
    }

    @down
    public static function down() {
        var statSave:StatSave = {
            statCommom: statCommon,
            statCommand: statCommand,
            statServers: statServers,
        }
        File.saveContent("statSave.txt",Json.stringify(statSave));
    }
}

typedef StatCommon = {
    var ?reqvDm:Int;
    var ?reqvSm:Int;
}

typedef StatCommand = {
    var ?name:String;
    var ?reqv:Int;
}

typedef StatServers = {
    var ?servId:String;
    var ?reqv:Int;
}

typedef StatSave = {
    var ?statCommom:StatCommon;
    var ?statCommand:Array<StatCommand>;
    var ?statServers:Array<StatServers>;
}