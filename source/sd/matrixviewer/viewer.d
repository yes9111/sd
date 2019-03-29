module sd.matrixviewer.viewer;

import std.range : enumerate;
import std.algorithm : each, map;

import d2sqlite3;

import gobject.Value;
import gtk.Window;
import gtk.ListStore;

import sd.type.matrix;
import sd.sql.util;

/**
Window that will display arbitrary SQL query results (matrixes)
*/
class MatrixViewer : Window
{
	private ListStore store;

	/**
	Constructs a matrix viewer, given a result matrix 
	*/
	this(Matrix matrix)
	{
		super("Results");

		store = createStore(matrix);
		setupView(matrix);
		setDefaultSize(640, 480);
		showAll();
	}

	private void setupView(Matrix matrix)
	{
		import gtk.TreeView : TreeView;
		import gtk.TreeViewColumn : TreeViewColumn;
		import gtk.ScrolledWindow : ScrolledWindow;
		import gtk.CellRendererText : CellRendererText;

		auto tree = new TreeView(store);

		foreach (index, col; matrix.columns.enumerate)
		{
			tree.appendColumn(new TreeViewColumn(col.name,
					new CellRendererText(), "text", cast(uint) index));
		}
		auto scrolledWindow = new ScrolledWindow();
		scrolledWindow.add(tree);
		add(scrolledWindow);
	}

	private ListStore createStore(Matrix matrix)
	{
		import gtk.TreeIter : TreeIter;
		import std.array : array;

		auto types = matrix.columns.map!(c => c.type.toGType).array;

		auto store = new ListStore(types);
		TreeIter iter;
		foreach (row; matrix.results)
		{
			store.append(iter);

			row.enumerate.each!((field) {
				store.setValue(iter, cast(int) field.index, field.value.toGValue);
			});
		}
		return store;
	}
}
