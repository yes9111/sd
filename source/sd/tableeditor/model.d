module sd.tableeditor.model;

import d2sqlite3 : SQLDatabase = Database, Row, SqliteException, cached, TableColumnMetadata;
import sd.type.database : Database;
import sd.type.table;
import sd.type.column;
import sd.type.matrix;
import sd.base.modelevent;
import std.stdio;

class TableModel 
{
    private Table table;
    private Matrix results;

    public mixin ModelEvent!("table:run", void delegate(Table table, string sql, Matrix matrix)) onSQL;
    public mixin ModelEvent!("table:load", void delegate(Table table, Matrix matrix)) onLoad;


    this(in Database database, string table)
    {

        this.table = new Table(database, table);
    }

	ulong getPKIndex() const
	{
		return table.pkColumnIndex;
	}

    string getName() const
    {
        return table.tableName;
    }

    string getDB() const
    {
        return table.db.path;
    }

    const(Column[]) getColumns() const
    {
        return table.columns;
    }

    void runSQL(string sql)
    {
        try
        {
            auto sqlDB = SQLDatabase(table.db.path);
            auto results = sqlDB.execute(sql);
            auto data = new Matrix(results);
            onSQL.fire(table, sql, data);
        }
        catch(SqliteException e)
        {
            // do something
            //trace("SQL error: ");
        }
    }


}
