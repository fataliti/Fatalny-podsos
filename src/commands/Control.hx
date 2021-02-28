package commands;

import com.raidandfade.haxicord.types.structs.Status;
import com.raidandfade.haxicord.types.structs.Status.Activity;
import com.raidandfade.haxicord.types.Message;



class Control {

    @command(["kill"],"Выключить бота", "Нужно быть fataliti бота")
    public static function kill(m:Message, w:Array<String>) {
        if (m.getMember().user.id.id != "371690693233737740")
            return;

        Tools.saveData();
        Sys.exit(0);
    }

    @command(["setstatus"],"Установить статус боту", "Нужно быть fataliti бота")
    public static function status(m:Message, w:Array<String>)  {
        if (m.getMember().user.id.id != "371690693233737740")
            return;

        var type = Std.parseInt(w.shift());
        var a:Activity = {
            type: type,
            name: w.join(" "),
        };
        var s:Status = {
            game: a,
            afk: false,
            status: "online",
        };
        Bot.bot.setStatus(s);
    }

}