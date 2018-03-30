module sd.DBBrowser.AppModel;

import std.experimental.logger;
import std.typecons;
import sd.type.Table;
import sd.type.Matrix;
import sd.base.ModelEvent;
import sd.sql.util;

import d2sqlite3 : SQLDatabase = Database, cached;

class DBModel
{
public:
	mixin ModelEvent!("db:open", void delegate(Database)) onOpen;
	mixin ModelEvent!("db:close", void delegate(Database)) onClose;
	mixin ModelEvent!("db:sql", void delegate(Matrix)) onSQL;

	void addDB(string path)
	{
		import std.array;
		// what if db is already open?
		if((path in dbs) !is null){
			logf("Database %s is already open.", path);
			return;
		}

		logf("Opening database %s", path);

		auto db = SQLDatabase(path);
		auto results = db.execute("SELECT name FROM sqlite_master WHERE type='table'");
		auto tables = appender!(string[]);
		foreach(row; results)
		{
			tables.put(row.peek!string(0));
		}
		Database dbInfo = Database(path, tables.data);
		dbs[path] = dbInfo;
		onOpen.fire(dbInfo);
	}

	void removeDB(string db)
	{
		logf("Closing database %s", db);
		auto dbInfo = dbs[db];
		dbs.remove(db);
		onClose.fire(dbInfo);
	}

	void runSQL(string dbName, string sql)
	{
		assert((dbName in dbs) !is null);
		auto db = SQLDatabase(dbName);
		auto results = db.execute(sql).cached;
		Matrix matrix;
		matrix.set(getQueryColumns(db, sql), results);

		onSQL.fire(matrix);
	}
private:
	Database[string] dbs;
}


