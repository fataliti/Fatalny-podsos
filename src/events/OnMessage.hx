package events;

import haxe.rtti.Meta;
import commands.Info;
import commands.Statistic;
import com.raidandfade.haxicord.types.Message;

class OnMessage {

    

    public static function onMessage(m:Message) {

        if (m.mentions.length > 0) {
            if (m.mentions[0].id.id == Bot.bot.user.id.id) {
                Info.about(m);
            }
        }

        if (StringTools.startsWith(m.content, Bot.prefix)) {
            var words:Array<String> = m.content.split(" ");
            words = words.filter(function (w){ return (w.length > 0);});

            var comName = words.shift();
            comName = StringTools.replace(comName, Bot.prefix, "");
            if (Bot.commandMap.exists(comName)) {

                if (m.inGuild()) {
                    if (!m.getGuild().textChannels[m.channel_id.id].nsfw) {
                        m.reply({content: "ТОЛЬКО В NSFW КАНАЛЕ"});
                        return;
                    }
                }

                var command:Bot.Command = Bot.commandMap.get(comName);
                Reflect.callMethod(command._class, Reflect.field(command._class,command.command),[m, words]);
                
                Bot.db.request('INSERT OR IGNORE INTO stat(com) VALUES("${command.command}")');
                if (m.inGuild()) {
                    Bot.db.request('UPDATE stat SET ss = ss + 1 WHERE com = "${command.command}"');
                    
                    Bot.db.request('INSERT OR IGNORE INTO statserv(servId) VALUES("${m.getGuild().id.id}")');
                    Bot.db.request('UPDATE statserv SET reqv = reqv + 1 WHERE servId = "${m.getGuild().id.id}"');
                } else {
                    Bot.db.request('UPDATE stat SET ls = ls + 1 WHERE com = "${command.command}"');
                }
            }
        }

        var classes = CompileTime.getAllClasses("commands");
        for (_class in classes) {
            var s = Reflect.fields(Meta.getStatics(_class)).filter((e) -> e == "message")[0];
            if (s != null) {
                Reflect.callMethod(_class, Reflect.field(_class, s), [m]);
            }
        }

    }
}