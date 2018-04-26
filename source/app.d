import std.stdio;
import gtk.Application;
import sd.DBBrowser.Browser;

/**
 * SD GTK Application 
 */
class SDApp : Application{
    private enum APP_ID = "yes9111.sd";
public:
    /**
     * Some public documentation
     */
    this(){
        super(APP_ID, GApplicationFlags.FLAGS_NONE);
        addOnActivate((app){
            auto browser = new DBBrowser();
            addWindow(browser);
        });
    }
}

void main(string[] args){
    auto app = new SDApp();
    app.run(args);
}
