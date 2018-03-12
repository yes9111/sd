import std.stdio;
import gtk.Application;

import sd.MainWindow;
import sd.AppModel;

class SDApp : Application
{
	private enum APP_ID = "yes9111.sd";
	this()
	{
		super(APP_ID, GApplicationFlags.FLAGS_NONE);
		auto model = new AppModel();

		this.addOnActivate((app){
				auto appWindow = new SDMainWindow(model);
				writeln("App activated");
				addWindow(appWindow);
				});
	}
}

void main(string[] args)
{
	auto app = new SDApp();
	app.run(args);
}
