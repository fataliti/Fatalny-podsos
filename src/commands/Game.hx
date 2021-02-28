package commands;

import haxe.Timer;
import com.raidandfade.haxicord.types.Message;

class Game {
    @command(["mine", "сыграть в сапера"])
    public static function mine(m:Message) {
        var field = [for(x in 0...19) [for(y in 0...9) 0]];
        var bombs = 0;
        while (bombs < 10) {
            var x = Std.random(field.length);
            var y = Std.random(field[0].length);
            if (field[x][y] == 0) {
                field[x][y] = 9;
                for(ox in -1...2) {
                    for(oy in -1...2) {
                        if (field[x+ox] != null) {
                            if (y+oy>=0 && y+oy<field[0].length && field[x+ox][y+oy] != 9) {
                                field[x+ox][y+oy]++;
                            }
                        }
                    }
                }
                bombs++;
            }
        }
        var emojis = ["0️⃣", "1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣", "8️⃣", "☢️"];
        var str = "";
        var j = 0;
        while (j < field[0].length) {
            for(i in 0...field.length) {
                str += '||${emojis[field[i][j]]}||';
            }
            str += "\n";
            j++;
        }
        Tools.sendMessage(str, m.channel_id.id);
    }



    static var crossMap:Map<String, CrossGame> = new Map();

    static var crossEmoji =  ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣", "8️⃣", "9️⃣", "❌", "⭕️"];

    @command(["cross"], "сыграть в крестики нолики", ">пингПротивника")
    public static function cross(m:Message) {
        if (!m.inGuild()) {
            m.reply({content: "не работает в лс"});
            return;
        }

        if (m.mentions.length == 0) {
            m.reply({content: "не указано с кем играть"});
            return;
        }

        m.reply({content: "подготовка"}, function(mg, eg) {

            var field:Array<Array<Int>> = new Array();

            for(i in 0...3) {
                field.push([for (j in 0...3) i*3+j]);
            }

            var gid = mg.id.id;
            var ra = [m.author.id.id, m.mentions[0].id.id];
            var r = ra[Std.random(ra.length)];
            crossMap.set(gid, {field: field, p1: m.author.id.id, p2: m.mentions[0].id.id, move: r, msg: mg});
            

            var timer = new Timer(1000*60*2);
            timer.run = function () {
                crossMap.remove(gid);
                timer.stop();
            }


            var str = '';
            for (array in field) {
                for (i in array) {
                    str += crossEmoji[i];
                }
                str += '\n';
            }
            str += 'Ход игрока <@${crossMap[gid].move}>';
            mg.edit({content: str});
        });
    }


    @message
    public static function message(m:Message) {
        var game:CrossGame = null;

        var a = m.author.id.id;
        for (g in crossMap) {
            if (g.p1 == a || g.p2 == a) {
                game = g;
                break;
            }
        }

        if (game == null) return;
        if (m.author.id.id != game.move) return;

        var point = Std.parseInt(m.content);
        if (point == null) return;
       
        if (point >= 1 && point <= 9) {
            var was = game.move;

            point--;
            var p1 = Std.int(point / 3);
            var p2 = point - p1*3;
            if (game.field[p1][p2] < 9) {
                if (game.move == game.p1) {
                    game.field[p1][p2] = 9;
                    game.move = game.p2;
                } else {
                    game.field[p1][p2] = 10;
                    game.move = game.p1;
                }

                var str = '';
                for (array in game.field) {
                    for (i in array) {
                        str += crossEmoji[i];
                    }
                    str += '\n';
                }
                
                var n = was == game.p1 ? 9 : 10;  
                var win = chekWin(n, game.field);

                if (win) {
                    str += 'Победа игрока <@${was}>';
                    crossMap.remove(game.msg.id.id);
                } else {
                    str += 'Ход игрока <@${game.move}>';
                }

                game.msg.edit({content: str});
                m.delete();
            }
        }
    }
    

    static function chekWin(n:Int, field:Array<Array<Int>>):Bool {
        var offs = [[0,-1],[-1,-1],[-1,0],[-1,1]];
        for (i in 0...3) {
            for (j in 0...3) {
                for(off in offs) {
                    var win = true;
                    for (k in 0...3) {
                        var p1 = i + off[1] + off[1]*-1*k;
                        var p2 = j + off[0] + off[0]*-1*k;
                        var arr = field[p1];
                        if (arr != null && p2 >= 0 && p2 <= 2) {
                            if (arr[p2] != n) {
                                win = false;
                                break;
                            }
                        } else {
                            win = false;
                            break;
                        }
                    }
                    if(win == true) {
                        return win;
                    }
                }
            }
        }
        return false;
    }

}

typedef CrossGame = {
    p1:String,
    p2:String, 
    move:String, 
    field:Array<Array<Int>>, 
    msg:Message
}
