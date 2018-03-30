module sd.MatrixViewer.Viewer;

import std.experimental.logger;

import gobject.Value;
import gtk.Window;
import gtk.ListStore;
import sd.type.Matrix;
import d2sqlite3;

class MatrixViewer : Window
{
	private ListStore store;

	this(Matrix matrix)
	{
		super("Results");

		store = createStore(matrix);
		setupView(matrix);
		showAll();
	}

	void setupView(Matrix matrix)
	{
		import gtk.TreeView, gtk.TreeViewColumn;
		import gtk.ScrolledWindow;
		import gtk.CellRendererText;
		import std.conv : to;

		auto tree = new TreeView(store);

		foreach(i, column; matrix.columns)
		{
			tree.appendColumn(new TreeViewColumn(column.name, new CellRendererText(), "text", cast(uint)i));
		}
		auto scrolledWindow = new ScrolledWindow();
		scrolledWindow.add(tree);

		add(scrolledWindow);
	}

	ListStore createStore(Matrix matrix)
	{
		import gtk.TreeIter;
		import std.algorithm : map;
		import std.array : array;

		auto types = matrix.columns.map!(c => c.type.toGType).array;

		auto store = new ListStore(types);
		TreeIter iter;
		foreach(row; matrix.results)
		{
			store.append(iter);
			
			int i;
			foreach(field; row)
			{
				store.setValue(iter, i, field.toGValue);
				++i;
			}
		}
		return store;
	}
}

private GType toGType(SqliteType type)
{
	switch(type)
	{
		case SqliteType.INTEGER: return GType.INT;
		case SqliteType.TEXT: return GType.STRING;
		case SqliteType.FLOAT: return GType.FLOAT;
		case SqliteType.BLOB: return GType.STRING;
		case SqliteType.NULL: return GType.NONE;
		default: return GType.INVALID;
	}
}

private Value toGValue(ColumnData field)
{
	switch(field.type)
	{
		case SqliteType.INTEGER:
			return new Value(field.as!int);
		case SqliteType.TEXT:
			return new Value(field.as!string);
		case SqliteType.FLOAT:
			return new Value(field.as!float);
		case SqliteType.BLOB:
			return new Value(field.as!string);
		case SqliteType.NULL:
			return null;
		default:
			throw new Exception("Unknown SQLType.");
	}

}
