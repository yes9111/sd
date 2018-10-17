module sd.MatrixViewer.Viewer;

import std.experimental.logger;
import std.range : enumerate;
import std.algorithm;

import gobject.Value;
import gtk.Window;
import gtk.ListStore;
import sd.type.Matrix;
import sd.sql.util;
import d2sqlite3;

class MatrixViewer : Window
{
	private ListStore store;

	this(Matrix matrix)
	{
		super("Results");

		store = createStore(matrix);
		setupView(matrix);
		setDefaultSize(640, 480);
		showAll();
	}

	void setupView(Matrix matrix)
	{
		import gtk.TreeView, gtk.TreeViewColumn;
		import gtk.ScrolledWindow;
		import gtk.CellRendererText;
		import std.conv : to;

		auto tree = new TreeView(store);

		matrix.columns.enumerate.each!((col){
			tree.appendColumn(new TreeViewColumn(
					col.value.name,
					new CellRendererText(),
					"text",
					cast(uint) col.index
			));
		});

		auto scrolledWindow = new ScrolledWindow();
		scrolledWindow.add(tree);

		add(scrolledWindow);
	}

	ListStore createStore(Matrix matrix)
	{
		import gtk.TreeIter;
		import std.array : array;

		auto types = matrix.columns.map!(c => c.type.toGType).array;

		auto store = new ListStore(types);
		TreeIter iter;
		foreach(row; matrix.results)
		{
			store.append(iter);
			
			row.enumerate.each!((field){
				store.setValue(iter, cast(int) field.index, field.value.toGValue);
			});
		}
		return store;
	}
}

