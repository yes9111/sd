module sd.TableEditor.DataEditor.DataEditor;

import std.algorithm;

import gtk.Window;
import gtk.Widget;
import gtk.ListStore;
import d2sqlite3;

import sd.base.ModelEvent;
import sd.TableEditor.Model;
import sd.type.Column;

class DataEditor
{
	private Controller controller;
	private Model model;
	private View view;

	this(TableModel tableModel)
	{
		model = new Model(tableModel);
		controller = new Controller(model);
		view = new View(model, controller);
	}

	Widget getTopWidget()
	{
		return view.scrolledWindow;
	}
}

private class Controller
{
	Model model;

	this(Model model)
	{
		this.model = model;
	}
}

import std.typecons;

private class Model : ListStore
{
	private const Column[] columns;
	private const TableModel tableModel;
	private Nullable!ResultRange results;

	this(TableModel tableModel)
	{
		import sd.sql.util;
		import std.algorithm : map;
		import std.array : array;

		this.tableModel = tableModel;
		columns = tableModel.getColumns();

		super(columns.map!(c => c.type.toGType).array);
		loadNext();
	}

	void loadNext()
	{
		import gtk.TreeIter;
		import std.range : iota;
		import std.array : array;
		import sd.sql.util : toGValue;

		if(results.isNull)
		{

			auto db = Database(this.tableModel.getDB);
			results = db.execute("SELECT * FROM " ~ this.tableModel.getName()).nullable;
		}
		immutable n = 50;
		int[] cIndexes = iota(0, cast(int)columns.length).array;
		foreach(i; 0 .. n)
		{
			if(results.empty) break;

			import gobject.Value;
			Value[] vals;
			TreeIter iter;
			append(iter);

			auto row = results.front;
			auto fields = row.map!toGValue.array;
			foreach(col; row)
			{
				vals ~= col.toGValue();
			}
			setValuesv(iter, cIndexes, vals);
			results.popFront();
		}
	}
}

import gtk.TreeView;
import gtk.Frame;
import gtk.ScrolledWindow;

private class View
{
	private TreeView treeView;
	private ScrolledWindow scrolledWindow;

	this(Model model, Controller controller)
	{
		treeView = setupTreeView(model);
		scrolledWindow = new ScrolledWindow();
		scrolledWindow.add(treeView);
	}

	TreeView setupTreeView(Model model)
	{
		import gtk.TreeViewColumn : TreeViewColumn;
		import gtk.CellRendererText;

		auto view = new TreeView(model);

		foreach(i, col; model.columns){
			CellRendererText renderer = new CellRendererText();
			renderer.setProperty("editable", 1);
			renderer.setProperty("editable-set", 1);

			auto column = new TreeViewColumn(
				col.name,
				renderer,
				"text",
				cast(int)i
			);

			view.appendColumn(column);
		}
		return view;
	}

}
