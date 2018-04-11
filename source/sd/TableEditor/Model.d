module sd.TableEditor.Model;

import d2sqlite3 : SQLDatabase = Database, Row, SqliteException, cached, TableColumnMetadata;
import sd.type.Table;
import sd.type.Column;
import sd.type.Matrix;
import sd.base.ModelEvent;
import std.stdio;

class TableModel 
{
    private const Database database;
    private Table table;
    private Matrix results;
	private int pkColumnIndex;

    public mixin ModelEvent!("table:run", void delegate(Table table, string sql, Matrix matrix)) onSQL;
    public mixin ModelEvent!("table:load", void delegate(Table table, Matrix matrix)) onLoad;


    this(in Database database, string table)
    {
        import std.algorithm : map;
        import std.array : array;

        this.database = database;
        auto db = SQLDatabase(database.path);
        auto results = db.execute("PRAGMA table_info(" ~ table ~ ")");

		int i;
        Column[] columns = results
        .map!((row){
			auto name = row.peek!string(1);
			auto columnMeta = db.tableColumnMetadata(table, name);

			if(columnMeta.isPrimaryKey)
			{
				pkColumnIndex = i;
			}

			++i;
            return Column(
                name, 
				row.peek!string(2).parseSQLType
			);
        })
        .array;

        this.table = Table(table, columns);
    }

	int getPKIndex() const
	{
		return pkColumnIndex;
	}

    string getName() const
    {
        return table.table;
    }

    string getDB() const
    {
        return database.path;
    }

    const(Column[]) getColumns() const
    {
        return table.columns;
    }

    void runSQL(string sql)
    {
        import sd.sql.util : getQueryColumns;
        try
        {
            results.clear();

            auto db = SQLDatabase(database.path);

            results.set(getQueryColumns(db, sql), db.execute(sql).cached);

            onSQL.fire(table, sql, results);
        }
        catch(SqliteException e)
        {
            // do something
            //trace("SQL error: ");
        }
    }


}
