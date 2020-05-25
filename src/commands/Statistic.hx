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

    @command(["g__","stat"],"Краткая статистика использования бота")
    public static function stat(m:Message) {
        var glam = function(guilds:Array<Guild>, e:ErrorReport) {
            m.reply({content: Std.string(guilds.length) + ' серверов - ${statCommon.reqvDm} запросов в лс ${statCommon.reqvSm} запросов на серверах'});
        }
        Bot.bot.getGuilds({}, glam);
    }

    @command(["statCommand","statCom"],"Статистика вызова команд")
    public static function statCom(m:Message) {
        statCommand.sort(function (a,b) return b.reqv - a.reqv);
        var top = statCommand.slice(0, 6);

        var str:String = "";
        for(t in top) {
            str += '${t.name}: ${t.reqv}\n';
        }

        Tools.sendMessage(str, m.channel_id.id);
    }

    @command(["statServer","statServ"],"Статистика вызова команд по серверам")
    public static function statServer(m:Message) {
        statServers.sort(function (a,b) return b.reqv - a.reqv);
        var top = statServers.slice(0, 6);
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