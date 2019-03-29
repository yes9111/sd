module sd.tableeditor.dataeditor.editor;

import std.algorithm;
import std.experimental.logger;
import std.typecons : nullable, Nullable;

import gtk.Window;
import gtk.Widget;
import gtk.ListStore;
import d2sqlite3;

import sd.base.modelevent;
import sd.tableeditor.model;
import sd.type.column;

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

    /**
     * Interfaces with SQL database to update one field
     * Also updates the model to reflect that change.
     */
    void editColumn(string path, size_t cIndex, string newValue)
    {
        import std.format : format;
        import gobject.Value : Value;
        import gtk.TreeIter : TreeIter;

        assert(cIndex < model.columns.length);

        tracef("PK Index is %d for table %s", model.tableModel.getPKIndex,
                model.tableModel.getName);

        auto iter = new TreeIter(model, path);
        auto pkValue = iter.getValueInt(cast(int)model.tableModel.getPKIndex);

        auto col = model.columns[cIndex];

        tracef("Changing column number %d: %s", cIndex, col.name);

        auto db = Database(model.tableModel.getDB);

        auto stmtText = format("UPDATE %s SET %s=:value WHERE %s=:id", model.tableModel.getName(),
                col.name, model.tableModel.getColumns[model.tableModel.getPKIndex()].name);

        tracef("Prepared statement: ", stmtText);
        auto stmt = db.prepare(stmtText);
        stmt.bind(":id", pkValue);
        tracef("Binding values: \"%s\", %d", newValue, pkValue);

        import std.conv : to;

        switch (col.type)
        {
        case SqliteType.INTEGER:
            stmt.bind(":value", newValue.to!int);
            break;
        case SqliteType.FLOAT:
            stmt.bind(":value", newValue.to!float);
            break;
        case SqliteType.TEXT:
            stmt.bind(":value", newValue);
            break;
        default:
            errorf("Not sure how to set to column type: %d", col.type);
            return;
        }
        stmt.execute();
        trace("Updated table ", model.tableModel.getName);
        switch (col.type){
        case SqliteType.INTEGER:
            model.setValue(iter, cast(int) cIndex, newValue.to!int);
            break;
        case SqliteType.FLOAT:
            model.setValue(iter, cast(int) cIndex, newValue.to!float);
            break;
        case SqliteType.TEXT:
            model.setValue(iter, cast(int) cIndex, newValue);
            break;
        default:
            assert(false, "Should not reach this point");            
        }
    }
}

final private class Model : ListStore
{
    private const Column[] columns;
    private const TableModel tableModel;
    private Nullable!ResultRange results;

    this(TableModel tableModel)
    {
        import sd.sql.util : toGType;
        import std.algorithm : map;
        import std.array : array;
        import std.stdio : writeln;

        this.tableModel = tableModel;
        columns = tableModel.getColumns();
        auto types = columns.map!(c => c.type.toGType).array;
        foreach (i, type; types)
        {
            if (type == GType.NONE)
            {
                warningf("None type found (NULL) for column: ", columns[i].name);
            }
            else if (type == GType.INVALID)
            {
                warningf("Invalid type found for column: ", columns[i]);
            }
        }

        super(types);
        loadNext();
    }

    void loadNext()
    {
        import gtk.TreeIter : TreeIter;
        import std.range : iota;
        import std.array : array;
        import sd.sql.util : toGValue;

        if (results.isNull)
        {

            auto db = Database(this.tableModel.getDB);
            results = db.execute("SELECT * FROM " ~ this.tableModel.getName()).nullable;
        }

        foreach (row; results)
        {
            TreeIter iter;
            append(iter);
            int colIndex;
            foreach (col; row)
                setValue(iter, colIndex++, col.toGValue);
        }
    }
}

private class View
{
    import gtk.TreeView : TreeView;
    import gtk.Frame : Frame;
    import gtk.ScrolledWindow : ScrolledWindow;
    import gtk.CellRendererText : CellRendererText;

    private TreeView treeView;
    private ScrolledWindow scrolledWindow;
    private Controller controller;

    this(Model model, Controller controller)
    {
        this.controller = controller;
        treeView = setupTreeView(model);
        scrolledWindow = new ScrolledWindow();
        scrolledWindow.add(treeView);
    }

    private TreeView setupTreeView(Model model)
    {
        import gtk.TreeViewColumn : TreeViewColumn;

        auto createEditor(size_t colIndex)
        {
            return (string path, string newValue, CellRendererText _) {
                controller.editColumn(path, colIndex, newValue);
            };
        }

        auto view = new TreeView(model);

        foreach (i, col; model.columns)
        {
            CellRendererText renderer = new CellRendererText();
            renderer.setProperty("editable", 1);
            renderer.setProperty("editable-set", 1);
            //renderer.setProperty("column-index", i);
            renderer.addOnEdited(createEditor(i));

            auto column = new TreeViewColumn(col.name, renderer, "text", cast(int) i);

            view.appendColumn(column);
        }
        return view;
    }
}
