package commands;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.endpoints.Endpoints.ErrorReport;

@desc("Statistic","Модуль просмотра статистики использования бота")
class Statistic {

    @initialize
    public static function initialize() {  
        Bot.db.request("
            CREATE TABLE IF NOT EXISTS 'stat' (	
                'com' TEXT PRIMARY KEY, 
                'ss' INTEGER DEFAULT 0,
                'ls' INTEGER DEFAULT 0
            )
        ");

        Bot.db.request("
            CREATE TABLE IF NOT EXISTS 'statserv' (	
                'servId' TEXT PRIMARY KEY, 
                'reqv' INTEGER DEFAULT 0
            )
        ");
    }

    @command(["stat"],"Краткая статистика использования бота")
    public static function stat(m:Message) {
        var glam = function(guilds:Array<Guild>, e:ErrorReport) {
            var users = 0;
            for (guild in guilds) 
                users += guild.member_count;
            
            var req = Bot.db.request('SELECT SUM(ss),SUM(ls) FROM stat');
            
            var ss = req.getIntResult(0);
            var ls = req.getIntResult(1);
            m.reply({content:' `${Std.string(guilds.length)}` серверов, `${users}` пользователей - `${ls}` запросов в лс, `${ss}` запросов на серверах'});
        }
        Bot.bot.getGuilds({}, glam);
    }

    @command(["statcom",],"Статистика вызова команд")
    public static function statcom(m:Message) {
        var str:String = "";
        var reqv = Bot.db.request('SELECT com, ls+ss AS res FROM stat ORDER BY ls+ss DESC LIMIT 6');
        for (com in reqv) {
            str +='${com.com}: ${com.res}\n';
        }
        Tools.sendMessage(str, m.channel_id.id);
    }

    @command(["statloc"],"Сколько было выполнено комманд на этом сервере")
    public static function statloc(m:Message) {
        if (!m.inGuild())
            return;

        var reqv = Bot.db.request('SELECT reqv FROM statserv WHERE servId = "${m.getGuild().id.id}"').getIntResult(0);
        Tools.sendMessage('На этом сервере бот был вызван `${reqv}` раз', m.getChannel().id.id);
    }


}
