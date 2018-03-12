module sd.AppModel;

import std.stdio, std.typecons;
import sd.data.Table;

import d2sqlite3;

class AppModel
{
public:

	this()
	{
	}

	Nullable!Table addDB(string path)
	{
		import std.array;
		// what if db is already open?
		if((path in dbs) !is null){
			writefln("Database %s is already open.", path);
			return Nullable!Table.init;
		}

		writefln("Opening database %s", path);

		auto db = Database(path);
		auto results = db.execute("SELECT name FROM sqlite_master WHERE type='table'");
		auto tables = appender!(string[]);
		foreach(row; results)
		{
			tables.put(row.peek!string(0));
		}
		dbs[path] = Table(path, tables.data);
		return dbs[path].nullable;
	}

	void removeDB(string db)
	{
		writefln("Closing database %s", db);
		dbs.remove(db);
	}
private:
	Table[string] dbs;
}

