module sd.MainWindow;

import gtk.MainWindow;
import gtk.Label;
import gtk.Widget, gdk.Event;
import gtk.MenuBar, gtk.MenuItem, gtk.Menu;
import gtk.Box;
import gtk.FileChooserDialog;

import std.stdio;

import sd.AppModel;

class SDMainWindow : MainWindow
{
	private AppModel model;

	this(AppModel model)
	{
		super("Explore SQL");
		this.model = model;
		setDefaultSize(200, 100);

		auto box = new Box(GtkOrientation.VERTICAL, 5);
		add(box);

		box.packStart(getMenuBar(), false, false, 0);
		box.packStart(new Label("Hello World!"), true, false, 5);
		showAll();
	}

	MenuBar getMenuBar(){
		auto bar = new MenuBar();
		auto fileMenu = bar.append("File");
		fileMenu.append(new MenuItem(&onMenuActivate, "Open DB", "file.open"));
		fileMenu.append(new MenuItem(&onMenuActivate, "Close DB", "file.close"));
		fileMenu.append(new MenuItem(&onMenuActivate, "Exit", "file.exit"));
		return bar;
	}

	FileChooserDialog chooser;
	private void onMenuActivate(MenuItem item){
		string action = item.getActionName;
		switch(action)
		{
			case "file.open":
				if(chooser is null){
					chooser = new FileChooserDialog("DB to open", this, FileChooserAction.OPEN);
				}
				chooser.run();
				model.openDB(chooser.getFilename());
				chooser.hide();
				break;
			case "file.close":
				break;
			case "file.exit":
				break;
			default:
				stderr.writefln("Unknown menu action: %s", item.getActionName);
				break;
		}
	}

	override bool windowDelete(Event event, Widget widget)
	{
		exit(0, false);
		return false;
	}
}
