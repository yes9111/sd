import std.stdio;
import gtk.Application;

import sd.MainWindow;
import sd.AppModel;
import sd.AppController;

class SDApp : Application
{
private:
	enum APP_ID = 	"yes9111.sd";
	AppController 	controller;
public:
	this()
	{
		this(new AppModel());
	}

	this(AppModel model)
	{
		super(APP_ID, GApplicationFlags.FLAGS_NONE);
		controller = new AppController(model);

		this.addOnActivate((app){
			auto appWindow = new SDMainWindow(controller);
			addWindow(appWindow);
		});
	}
}

void main(string[] args)
{
	auto app = new SDApp();
	app.run(args);
}
