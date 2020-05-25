package commands;

import com.raidandfade.haxicord.types.Message;

class Control {
    @command(["kill", "restart"],"Перезапуск бота")
    public static function kill(m:Message) {
        if (m.getMember().user.id.id != "371690693233737740")
            return;

        Tools.saveData();
        Sys.exit(0);
    }


    public static function status() {
        
    }

}