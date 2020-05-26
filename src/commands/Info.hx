package commands;


import com.raidandfade.haxicord.types.structs.Embed;
import com.raidandfade.haxicord.types.structs.Embed.EmbedField;
import com.raidandfade.haxicord.types.Message;
import haxe.rtti.Meta;

class Info {
    @command(["about"], "Информация о боте")
    public static function about(m:Message) {

        var f1:EmbedField = {
            name: "Автор",
            value: "@Fataliti // Reifshneider#3923",
        }
        var f2:EmbedField = {
            name: "Написан на",
            value: "Haxe+Haxicord -> C++",
        }
        var embed:Embed = {
            author: {name: "Fatalny_podsos",icon_url: Bot.bot.user.avatarUrl, },
            fields: [f1, f2],
            color: 0xFF9900,
            title: "Сурсы",
            url: "https://github.com/fataliti/Fatalny-podsos",
            thumbnail: {url: "https://raw.githubusercontent.com/RaidAndFade/Haxicord/master/logos/haxicord.png",},
        }
        Tools.sendEmbed(embed, m.channel_id.id);
    }

    @command(["info", "help"], "Помощь по командам","команда[оционально] (иначе выведет информацию по всем командам)")
    public static function help(m:Message, words:Array<String>) {

        var shift = words.shift();
        if (shift != null) {
            var command = Bot.commandMap.get(shift);

            if (command == null) {
                Tools.reply(m, "Такой команды нет");
                return;
            }
            var _static = Meta.getStatics(command._class);
            var field   = Reflect.fields(_static).filter((e) -> e == command.command)[0];
            var refl    = Reflect.field(_static, field);


            var embed:Embed = {}
            embed.color = 0xFF9900;
            embed.author = { name: "Fatalny_podsos", icon_url: Bot.bot.user.avatarUrl,}
            embed.fields = [{name: refl.command[0].join(", "), value: '${refl.command[1]}',}];

            if (refl.command[2] != null) {
                embed.fields.push({name:"Использование", value: '${refl.command[0].join(", ")} ${refl.command[2]}'});
            }

            Tools.sendEmbed(embed, m.channel_id.id);
        } else {
            var classList = CompileTime.getAllClasses("commands");
            var answer = "";
  
            for (_class in classList) {
                var statics = Meta.getStatics(_class);
                for(s in Reflect.fields(statics)) {
                    if (s == "initialize" || s == "down" || s == "rectionAdd")
                        continue;
                    
                    var field = Reflect.field(statics, s);
                    answer += '**${field.command[0].join(", ")}**: ${field.command[1]}\n';
                } 
            }
            Tools.sendMessage(answer, m.channel_id.id);
        }
    }

    @command(["invite"], "Ссылка для добавления бота на свой сервер") 
    public static function invite(m:Message) {
        Tools.reply(m, 'Приглашение для бота: ${Bot.bot.getInviteLink()}');
    }

}