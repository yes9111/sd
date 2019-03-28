module sd.dbbrowser.browser;

import gtk.MainWindow;
import gtk.Label;
import gtk.Widget, gdk.Event;
import gtk.MenuBar, gtk.MenuItem, gtk.Menu;
import gtk.Notebook;
import gtk.Box;
import gtk.FileChooserDialog;
import gtk.ListStore;
import gtk.TreeView;

import std.conv, std.typecons, std.experimental.logger;

import sd.dbbrowser.controller;
import sd.dbbrowser.model;
import sd.type.table;
import sd.type.database : Database;
import sd.type.matrix;

/**
Top level window to handle browsing/selecting databases
*/
final class DBBrowser : MainWindow
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
		model.onSQL.register(&this.showSQLResults);

		setDefaultSize(800, 600);
		setup();
		showAll();
	}

private:
	Notebook notebook;
	string[] openDBs;

	void setup()
	{
		auto box = new Box(GtkOrientation.VERTICAL, 5);
		add(box);
		notebook = createNotebook();

		box.packStart(createMenuBar(), false, false, 0);
		box.packStart(notebook, true, true, 0);
	}

	MenuBar createMenuBar(){
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
			immutable pageIndex = notebook.getCurrentPage();
			if(pageIndex == -1) return;
			controller.closeDB(openDBs[pageIndex]);
			break;
		case "file.exit":
			break;
		default:
			errorf("Unknown menu action: %s", action);
			break;
		}
	}

	void addDB(in Database database){
		import std.path : baseName;
		import gtk.TreeIter : TreeIter;
		import gtk.TreeViewColumn: TreeViewColumn;
		import gtk.CellRendererText : CellRendererText;
		import gtk.Entry : Entry;
		import gtk.Grid : Grid;

		auto store = new ListStore([ GType.STRING ]);
		auto list = new TreeView(store);
		auto column = new TreeViewColumn("Table", new CellRendererText(), "text", 0);
		list.appendColumn(column);
		list.setHexpand(true);
		list.setVexpand(true);

		auto entry = new Entry();
		entry.setPlaceholderText("Query custom SQL here");
		entry.addOnActivate((Entry entry){
			logf("Running SQL: %s", entry.getText());
			controller.runSQL(openDBs[notebook.getCurrentPage()], entry.getText());
		});
		entry.setHexpand(true);

		auto grid = new Grid();
		grid.setOrientation(GtkOrientation.VERTICAL);

		grid.add(entry);
		grid.add(list);

		TreeIter iter;
		foreach(table; database.tables)
		{
			store.append(iter);
			store.setValue(iter, 0, table);
		}

		list.addOnRowActivated((path, column, view){
			import sd.tableeditor.tableeditor: TableEditor;

			TreeIter row = new TreeIter();
			store.getIter(row, path);
			string tableName = row.getValueString(0);
			try
			{
				new TableEditor(database, tableName);
			}
			catch(Exception e)
			{
				errorf("Failed to create table editor for table %s: Exception %s",
					tableName,
					e, 
				);
			}
		});

		openDBs ~= database.path;
		notebook.appendPage(grid, database.path.baseName);
		notebook.showAll();
	}

	void removeDB(in Database db)
	{
		int index;
		while(index < openDBs.length && openDBs[index] != db.path)
			++index;

		assert(index < openDBs.length);
		notebook.removePage(index);

		while(index < openDBs.length-1)
		{
			openDBs[index] = openDBs[index+1];
			++index;
		}
		openDBs = openDBs[0 .. $-1];
	}

	void showSQLResults(Matrix results)
	{
		import sd.matrixviewer.viewer;
		auto viewer = new MatrixViewer(results);
	}

protected:
	override bool windowDelete(Event event, Widget widget)
	{
		exit(0, false);
		return false;
	}
}
