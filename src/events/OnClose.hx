package events;

class OnClose {
    public static function onClose(c:Int) {
        Tools.saveData();
        Sys.exit(0);
    }
}