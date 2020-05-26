package events;

import commands.Statistic;
import com.raidandfade.haxicord.types.Message;

class OnMessage {
    public static function onMessage(m:Message) {
        if (StringTools.startsWith(m.content, Bot.prefix)) {
            var words:Array<String> = m.content.split(" ");
            words = words.filter(function (w){ return (w.length > 0);});

            var comName = words.shift();
            comName = StringTools.replace(comName, Bot.prefix, "");
            if (Bot.commandMap.exists(comName)) {
                var command:Bot.Command = Bot.commandMap.get(comName);
                Reflect.callMethod(command._class, Reflect.field(command._class,command.command),[m, words]);

                var comStat = Statistic.statCommand.filter((c) -> c.name == command.command)[0];
                if (comStat != null) {
                    comStat.reqv++;
                } else {
                    var _comStat:StatCommand =  {
                        name : command.command,
                        reqv : 1
                    }
                    Statistic.statCommand.push(_comStat);
                }

                if (m.inGuild()) {
                    Statistic.statCommon.reqvSm++;

                    var servStat = Statistic.statServers.filter((s) -> s.servId == m.getGuild().id.id)[0];
                    if (servStat != null) {
                        servStat.reqv++;
                    } else {
                        var _servStat:StatServers = {
                            servId: m.getGuild().id.id,
                            reqv: 1,
                        }
                        Statistic.statServers.push(_servStat);
                    }
                } else 
                    Statistic.statCommon.reqvDm++;
            }
        }
    }
}