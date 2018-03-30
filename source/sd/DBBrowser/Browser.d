module sd.DBBrowser.Browser;

import gtk.MainWindow;
import gtk.Label;
import gtk.Widget, gdk.Event;
import gtk.MenuBar, gtk.MenuItem, gtk.Menu;
import gtk.Notebook;
import gtk.Box;
import gtk.FlowBox;
import gtk.FileChooserDialog;
import gtk.ListStore;
import gtk.TreeView;
import std.typecons;

import std.stdio, std.conv;

import sd.DBBrowser.Controller;
import sd.DBBrowser.AppModel;
import sd.type.Table;

class DBBrowser : MainWindow
{
	private Controller controller;
	private DBModel model;

	this()
	{
		super("Explore SQL");
		model = new DBModel();
		controller = new Controller(model);

		model.onOpen.register(&this.addDB);
		model.onClose.register(&this.removeDB);

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
			controller.openDB(dbFile);
			break;
		case "file.close":
			int pageIndex = notebook.getCurrentPage();
			if(pageIndex == -1) return;
			string db = (cast(Label)notebook.getTabLabel(notebook.getNthPage(pageIndex))).getText();
			controller.closeDB(db);
			break;
		case "file.exit":
			break;
		default:
			stderr.writefln("Unknown menu action: %s", item.getActionName);
			break;
		}
	}

	void addDB(in Database database){
		import std.path;
		import gtk.TreeIter;
		import gtk.TreeViewColumn;
		import gtk.CellRendererText;

		string label = database.path.baseName;

		auto store = new ListStore([ GType.STRING ]);
		auto list = new TreeView(store);
		auto column = new TreeViewColumn("Table", new CellRendererText(), "text", 0);
		list.appendColumn(column);

		foreach(table; database.tables){
			TreeIter iter;
			store.append(iter);
			store.setValue(iter, 0, table);
		}

		list.addOnRowActivated((path, column, view){
			import sd.TableEditor.TableEditor;

			TreeIter row = new TreeIter();
			store.getIter(row, path);
			
			string table = row.getValueString(0);

			auto editor = new TableEditor(database, table);
		});

		notebook.appendPage(list, label);
		notebook.showAll();
	}

	void removeDB(in Database event)
	{
		notebook.removePage(notebook.getCurrentPage());
	}

protected:
	override bool windowDelete(Event event, Widget widget)
	{
		exit(0, false);
		return false;
	}
}
