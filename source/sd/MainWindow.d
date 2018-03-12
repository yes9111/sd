module sd.MainWindow;

import gtk.MainWindow;
import gtk.Label;
import gtk.Widget, gdk.Event;
import gtk.MenuBar, gtk.MenuItem, gtk.Menu;
import gtk.Notebook;
import gtk.Box;
import gtk.FlowBox;
import gtk.FileChooserDialog;
import std.typecons;

import std.stdio, std.conv;

import sd.AppController;

class SDMainWindow : MainWindow
{
	private AppController controller;
	private FlowBox dbList;

	this(AppController controller)
	{
		super("Explore SQL");
		this.controller = controller;
		setDefaultSize(800, 600);
		setup();
		showAll();
	}

private:
	Notebook notebook;

	void setup()
	{
		auto box = new Box(GtkOrientation.VERTICAL, 5);
		add(box);
		notebook = createNotebook();

		box.packStart(getMenuBar(), false, false, 0);
		box.packStart(notebook, true, true, 5);
	}


	MenuBar getMenuBar(){
		auto bar = new MenuBar();
		auto fileMenu = bar.append("File");
		fileMenu.append(new MenuItem(&onMenuActivate, "Open DB", "file.open"));
		fileMenu.append(new MenuItem(&onMenuActivate, "Close DB", "file.close"));
		fileMenu.append(new MenuItem(&onMenuActivate, "Exit", "file.exit"));
		return bar;
	}

	Notebook createNotebook(){
		auto notebook = new Notebook();
		notebook.setTabPos(PositionType.TOP);
		return notebook;
	}

	FileChooserDialog chooser;
	void onMenuActivate(MenuItem item){
		import std.path;

		string action = item.getActionName;
		switch(action)
		{
		case "file.open":
			if(chooser is null){
				chooser = new FileChooserDialog("DB to open", this, FileChooserAction.OPEN);
			}
			chooser.run();
			scope(exit) chooser.hide();

			string dbFile = chooser.getFilename();
			writeln("Trying to open: ", dbFile);

			auto db = controller.openDB(dbFile);
			if(!db.isNull)
			{
				string label = db.path.baseName;
				auto box = new Box(GtkOrientation.VERTICAL, 5);

				foreach(table; db.tables)
				{
					box.packStart(new Label(table), false, false, 5);
				}

				notebook.appendPage(box, label);
				notebook.showAll();
			}
			break;
		case "file.close":
			int pageIndex = notebook.getCurrentPage();
			if(pageIndex == -1) return;
			string db = (cast(Label)notebook.getTabLabel(notebook.getNthPage(pageIndex))).getText();
			controller.closeDB(db);
			notebook.removePage(pageIndex);
			break;
		case "file.exit":
			break;
		default:
			stderr.writefln("Unknown menu action: %s", item.getActionName);
			break;
		}
	}

protected:
	override bool windowDelete(Event event, Widget widget)
	{
		exit(0, false);
		return false;
	}
}
