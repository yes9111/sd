module sd.DBBrowser.AppModel;

import std.stdio, std.typecons;
import sd.type.Table;
import sd.base.ModelEvent;

import d2sqlite3 : SQLDatabase = Database;

class DBModel
{
public:
	mixin ModelEvent!("db:open", void delegate(Database)) onOpen;
	mixin ModelEvent!("db:close", void delegate(Database)) onClose;

	void addDB(string path)
	{
		import std.array;
		// what if db is already open?
		if((path in dbs) !is null){
			writefln("Database %s is already open.", path);
			return;
		}

		writefln("Opening database %s", path);

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
		writefln("Closing database %s", db);
		auto dbInfo = dbs[db];
		dbs.remove(db);
		onClose.fire(dbInfo);
	}
private:
	Database[string] dbs;
}

