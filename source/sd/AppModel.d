module sd.AppModel;

import std.stdio;

class AppModel
{
	private string[string] dbs;

	this()
	{
	}

	string openDB(string path)
	{
		import std.path;

		auto name = path.baseName;
		// what if db is already open?
		if((name in dbs) !is null){
			writefln("Database %s is already open.", name);
			return name;
		}

		writefln("Opening database %s", name);
		dbs[name] = path;
		return name;

	}

	void closeDB(string db)
	{
		writefln("Closing database %s", db);
		dbs.remove(db);
	}
}
