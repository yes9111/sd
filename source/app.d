import std.stdio;
import gtk.Application;

import sd.MainWindow;

class SDApp : Application
{
	private enum APP_ID = "yes9111.sd";
	this()
	{
		super(APP_ID, GApplicationFlags.FLAGS_NONE);
		this.addOnActivate((app){
				auto appWindow = new SDMainWindow();
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
