module sd.type.database;

import d2sqlite3 : SQLDatabase = Database;

/// Represents a database metadata
class Database
{
	/// Reads an SQL db file and constructs metadata 
	/// information
	this(string path)
	{
		import std.algorithm : map;
		import std.range : array;
		this.path = path;
		auto db = SQLDatabase(path);
		auto results = db.execute("SELECT name FROM sqlite_master WHERE type='table'");
		tables = results.map!(row => row.peek!string(0)).array.idup;
	}

	immutable string path;
	immutable string[] tables;
}