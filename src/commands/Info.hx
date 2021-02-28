package commands;

import com.raidandfade.haxicord.types.structs.Embed;
import com.raidandfade.haxicord.types.structs.Embed.EmbedField;
import com.raidandfade.haxicord.types.Message;
import haxe.rtti.Meta;

@desc("Info","Модуль информации о модулях/командах")
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
        var f3:EmbedField = {
            name: "Дайте деняк",
            value: "https://qiwi.com/n/REIFSHNEIDER https://money.yandex.ru/to/4100111915700580",
        }
        var embed:Embed = {
            author: {name: "Fatalny_podsos",icon_url: Bot.bot.user.avatarUrl, },
            fields: [f1, f2, f3],
            color: 0xFF9900,
            title: "Сурсы",
            url: "https://github.com/fataliti/Fatalny-podsos",
            thumbnail: {url: "https://raw.githubusercontent.com/RaidAndFade/Haxicord/master/logos/haxicord.png",},
        }
        Tools.sendEmbed(embed, m.channel_id.id);
    }

    @command(["info", "help"], "Показать модули либо информацию о конкретном модуле/команде"," ?модуль|команда")
    public static function help(m:Message, words:Array<String>) {
        var shift = words.shift();
        if (shift != null) {

            var command = Bot.commandMap.get(shift);
            if (command != null){
                var _static = Meta.getStatics(command._class);
                var field   = Reflect.fields(_static).filter((e) -> e == command.command)[0];
                var refl    = Reflect.field(_static, field);

                var embed:Embed = {}
                embed.color = 0xFF9900;
                embed.author = { name: "Fatalny_podsos", icon_url: Bot.bot.user.avatarUrl,}
                embed.fields = [{name: refl.command[0].join(", "), value: '${refl.command[1]}',}];

                if (refl.command[2] != null) {
                    embed.fields.push({name:"Использование", value: '${Bot.prefix}${refl.command[0].join("|")} ${refl.command[2]}'});
                }

                Tools.sendEmbed(embed, m.channel_id.id);
            } else {
                var classList = CompileTime.getAllClasses("commands");
                var mod = classList.filter(_class -> Type.getClassName(_class).indexOf(shift) > -1).first();
               
                if (mod == null) return;
                
                var meta = Meta.getType(mod);
                var refl = Reflect.field(meta, "desc");
                if (refl == null) return;
                var embed:Embed = {}
                embed.color = 0xFF9900;
                embed.author = { name: refl[0], icon_url: Bot.bot.user.avatarUrl,}
                embed.description = refl[1];


                var commands = Meta.getStatics(mod);
                var comlist  = "";
                for(com in Reflect.fields(commands)) {
                    var filds = Reflect.field(commands, com);
                    if (!Reflect.hasField(filds, "command")) continue;
                    comlist += '`${filds.command[0].join('|')}` ${filds.command[1]}\n';
                }

                embed.fields = [{
                    name: 'Команды модуля:',
                    value: comlist,
                }];

                Tools.sendEmbed(embed, m.channel_id.id);
            }
        } else {
            
            var classList = CompileTime.getAllClasses("commands");

            var embed:Embed = {}
            embed.color = 0xFF9900;
            embed.author = { name: "Fatalny_podsos", icon_url: Bot.bot.user.avatarUrl,}
            embed.footer = {text: '${Bot.prefix}help|info ?команда/модуль'}
            var embFild:EmbedField = {name: 'Модули', value: ''};
            
            for (_class in classList) {
                var refl = Reflect.field(Meta.getType(_class), "desc");
                if (refl == null) continue;
                embFild.value += '`${refl[0]}` ${refl[1]}\n';
            }
            embed.fields = [embFild];
            Tools.sendEmbed(embed, m.channel_id.id);
        }
    }

    @command(["invite"], "Ссылка для добавления бота на свой сервер") 
    public static function invite(m:Message) {
        Tools.reply(m, 'Приглашение для бота: ${Bot.bot.getInviteLink()}');
    }

    @command(["ison"], "Проверить отвечает ли бот")
    public static function ison(m:Message)  {
        Tools.reply(m, "да-да, я работаю");
    }

}