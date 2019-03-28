module sd.tableeditor.view;

import gtk.Window;
import gtk.TreeView;
import gtk.ListStore;
import gtk.Label;
import gtk.TreeViewColumn;
import gtk.TreeIter;
import gtk.Notebook;
import gtk.Grid;
import sd.tableeditor.model;
import sd.type.column;

class StructureEditor : Window
{
    private Notebook notebook;
    private TableModel model;

    this(TableModel model)
    {
        this.model = model;
        super("Table: " ~ model.getName());
        setDefaultSize(800, 600);
        setBorderWidth(5);
        notebook = new Notebook();

        addStructureEditor(notebook, model);
        addDataBrowser(notebook, model);

        add(notebook);
    }

    private void addStructureEditor(Notebook notebook, TableModel model)
    {
        auto columnsStore = new ListStore([GType.STRING, GType.STRING]);

        foreach (column; model.getColumns())
        {
            TreeIter iter;
            columnsStore.append(iter);
            columnsStore.setValue(iter, StructureColumns.NAME, column.name);
            columnsStore.setValue(iter, StructureColumns.TYPE, column.type.toString());
        }
        import gtk.CellRendererText : CellRendererText;

        auto view = new TreeView(columnsStore);
        view.appendColumn(new TreeViewColumn("Name", new CellRendererText(),
                "text", StructureColumns.NAME));
        view.appendColumn(new TreeViewColumn("Type", new CellRendererText(),
                "text", StructureColumns.TYPE));
        notebook.appendPage(view, new Label("Structure"));
    }

    private void addDataBrowser(Notebook notebook, TableModel model)
    {
        import sd.tableeditor.dataeditor.editor : DataEditor;

        auto editor = new DataEditor(model);

        notebook.appendPage(editor.getTopWidget(), new Label("Data Browser"));
    }

    private enum StructureColumns
    {
        NAME = 0,
        TYPE,
        NCOLUMNS
    }
}
