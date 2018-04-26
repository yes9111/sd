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
    
    /**
     * Interfaces with SQL database to update one field
     * Also updates the model to reflect that change.
     */
    void editColumn(string path, size_t cIndex, string newValue)
    {
		import std.format : format;
		import std.experimental.logger : log, logf;
		import gobject.Value : Value;
        import gtk.TreeIter : TreeIter;
        
        assert(cIndex < model.columns.length);

        
		logf("PK Index is %d for table %s", model.tableModel.getPKIndex, model.tableModel.getName);
        
        auto iter = new TreeIter(model, path);
        auto pkValue = iter.getValueInt(model.tableModel.getPKIndex);
        
        auto colName = model.columns[cIndex].name;
        
        logf("Changing column number %d: %s", cIndex, colName);
        
        auto db = Database(model.tableModel.getDB);
        
		auto stmtText = format("UPDATE %s SET %s=:value WHERE %s=:id", 
            model.tableModel.getName(), 
            colName, 
            model.tableModel.getColumns[model.tableModel.getPKIndex()].name);
        
		log("Prepared statement: ", stmtText);
        auto stmt = db.prepare(stmtText);
		logf("Binding values: \"%s\", %d", newValue, pkValue);
		stmt.bindAll(newValue, pkValue);
        stmt.execute();
        
        log("Updated table ", model.tableModel.getName);
        model.setValue(iter, cast(int)cIndex, newValue);
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
        import sd.sql.util : toGType;
        import std.algorithm : map;
        import std.array : array;
        import std.stdio : writeln;

        this.tableModel = tableModel;
        columns = tableModel.getColumns();
        auto types = columns.map!(c => c.type.toGType).array;
        foreach(i, type; types)
        {
            if(type == GType.NONE)
            {
                writeln("None type found (NULL) for column: ", columns[i].name);
            }
            else if(type == GType.INVALID)
            {
                writeln("Invalid type found for column: ", columns[i]);
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

        if(results.isNull)
        {

            auto db = Database(this.tableModel.getDB);
            results = db.execute("SELECT * FROM " ~ this.tableModel.getName()).nullable;
        }
        
        foreach(row; results)
        {
            TreeIter iter;
            append(iter);
            int colIndex;
            foreach(col; row)
                setValue(iter, colIndex++, col.toGValue);
        }
    }
}

import gtk.TreeView;
import gtk.Frame;
import gtk.ScrolledWindow;
import gtk.CellRendererText;

private class View
{
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

    TreeView setupTreeView(Model model)
    {
        import gtk.TreeViewColumn : TreeViewColumn;

        auto createEditor(int colIndex)
        {
            return (string path, string newValue, CellRendererText renderer){
                controller.editColumn(path, colIndex, newValue);
            };
        }
        
        auto view = new TreeView(model);

        foreach(i, col; model.columns){
            CellRendererText renderer = new CellRendererText();
            renderer.setProperty("editable", 1);
            renderer.setProperty("editable-set", 1);
            //renderer.setProperty("column-index", i);
            renderer.addOnEdited(createEditor(cast(int)i));

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
