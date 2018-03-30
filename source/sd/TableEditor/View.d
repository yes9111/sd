module sd.TableEditor.View;

import gtk.Window;
import gtk.TreeView;
import gtk.ListStore;
import gtk.Label;
import gtk.TreeViewColumn;
import gtk.TreeIter;
import gtk.Notebook;
import gtk.Entry;
import gtk.Grid;
import sd.TableEditor.Model;
import sd.type.Column;

class StructureEditor : Window
{
    private Notebook notebook;
    private TableModel model;

	this(TableModel model)
	{
        this.model = model;
		super("Table: " ~ model.getName());
        setBorderWidth(5);
        notebook = new Notebook();

        addStructureEditor(notebook, model);
        addDataBrowser(notebook, model);

        add(notebook);
	}

    private void addStructureEditor(Notebook notebook, TableModel model)
    {
        import std.algorithm : each;
        auto columnsStore = new ListStore([GType.STRING, GType.STRING]);
        foreach(column; model.getColumns())
        {
            TreeIter iter;
            columnsStore.append(iter);
            columnsStore.setValue(iter, StructureColumns.NAME, column.name);
            columnsStore.setValue(iter, StructureColumns.TYPE, type2str(column.type));
        }
        auto view = setupTreeView(columnsStore);
        notebook.appendPage(view, new Label("Structure"));
    }

    private void addDataBrowser(Notebook notebook, TableModel model)
    {
        auto grid = new Grid();
        grid.setOrientation(GtkOrientation.VERTICAL);
        auto label = new Label("_Hello World", true);
        label.setHexpand(true);
        label.setVexpand(true);
        grid.add(label);

        notebook.appendPage(grid, new Label("Data"));
    }

	enum StructureColumns
	{
		NAME = 0,
		TYPE,
		NCOLUMNS
	}

	TreeView setupTreeView(ListStore store)
	{
		import gtk.CellRendererText;

		auto view = new TreeView(store);

		auto column = new TreeViewColumn("Name", new CellRendererText(), "text", StructureColumns.NAME);
		view.appendColumn(column);
		column = new TreeViewColumn("Type", new CellRendererText(), "text", StructureColumns.TYPE);
		view.appendColumn(column);
		return view;
	}
}

