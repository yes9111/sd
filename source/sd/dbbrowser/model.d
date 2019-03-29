module sd.dbbrowser.model;

import std.experimental.logger;
import std.typecons;
import sd.type.database : Database;
import sd.type.matrix;
import sd.base.modelevent;
import sd.sql.util;

import d2sqlite3 : SQLDatabase = Database, cached;

/// Model for DB Browser window
package final class DBBrowserModel
{
public:
	mixin ModelEvent!("db:open", void delegate(Database)) onOpen;
	mixin ModelEvent!("db:close", void delegate(Database)) onClose;
	mixin ModelEvent!("db:sql", void delegate(Matrix)) onSQL;

	void addDB(string path)
	{
		import std.array : array;

		// what if db is already open?
		if ((path in dbs) !is null)
		{
			logf("Database %s is already open.", path);
			return;
		}

		logf("Opening database %s", path);

		auto db = new Database(path);
		dbs[path] = db;
		onOpen.fire(db);
	}

	void removeDB(string dbKey)
	{
		logf("Closing database %s", dbKey);
		auto db = dbs[dbKey];
		dbs.remove(dbKey);
		onClose.fire(db);
	}

	void runSQL(string dbName, string sql)
	{
		import d2sqlite3 : SqliteException;
		assert((dbName in dbs) !is null);
		auto db = SQLDatabase(dbName);
		try{
			auto results = db.execute(sql);
			auto matrix = new Matrix(results);
			onSQL.fire(matrix);
		}
		catch(SqliteException ex){
			errorf("SQL exception: %s", ex.toString());
		}

	}

private:
	Database[string] dbs;
}
