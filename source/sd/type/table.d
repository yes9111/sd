module sd.type.table;

import d2sqlite3 : SQLDatabase = Database;
import sd.type.database;
import sd.type.column;

/// represents an SQL table
class Table
{
	/// Read SQL table metadata from a given 
	/// database and a table name
	this(const Database db, string tableName)
	{
		import std.algorithm : map;
		import std.array : array;		
		this.db = db;
		this.tableName = tableName;
		auto sqlDB = SQLDatabase(db.path);
		auto results = sqlDB.execute("PRAGMA table_info(" ~ tableName ~ ")");

		size_t i, pki;
		columns = results.map!((row) {
			auto columnName = row.peek!string(1);
			const columnMeta = sqlDB.tableColumnMetadata(tableName, columnName);

			if (columnMeta.isPrimaryKey)
			{
				pki = i;
			}

			++i;
			return Column(columnName, row.peek!string(2).parseSQLType);
		}).array;
		pkColumnIndex = pki;

	}

	const Database db;
	immutable string tableName;
	immutable size_t pkColumnIndex;
	Column[] columns;
}
