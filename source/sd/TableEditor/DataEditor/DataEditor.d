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
		return view.treeView;
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

private class Model : ListStore
{
	private const Column[] columns;
	this(TableModel tableModel)
	{
		import sd.sql.util;
		import std.algorithm : map;
		import std.array : array;

		columns = tableModel.getColumns();

		super(columns.map!(c => c.type.toGType).array);
		loadNext();
	}

	void loadNext()
	{
	}
}

import gtk.TreeView;
import gtk.Frame;

private class View
{
	private TreeView treeView;

	this(Model model, Controller controller)
	{
		treeView = setupTreeView(model);
	}

	TreeView setupTreeView(Model model)
	{
		import gtk.TreeViewColumn : TreeViewColumn;
		auto view = new TreeView(model);

		model.columns.each!((col){
			view.appendColumn(new TreeViewColumn());
		});
		return view;
	}

}
