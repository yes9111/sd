module sd.type.Column;

public import d2sqlite3 : SqliteType;

string toString(SqliteType t)
{
	switch(t)
	{
	case SqliteType.INTEGER: return "Integer";
	case SqliteType.TEXT: return "Text";
	case SqliteType.FLOAT: return "Float";
	case SqliteType.BLOB: return "Blob";
    case SqliteType.NULL: return "NULL";
	default: throw new Exception("Unknown SQLType: ");
	}
}

SqliteType parseSQLType(string str)
{
    import std.regex : ctRegex, matchFirst;

    immutable SqliteType[string] typeMap = [
        "INTEGER": SqliteType.INTEGER,
        "INT": SqliteType.INTEGER,
        "NVARCHAR": SqliteType.TEXT,
        "TEXT": SqliteType.TEXT,
        "DATETIME": SqliteType.FLOAT,
        "NUMERIC": SqliteType.FLOAT
    ];

    auto r = ctRegex!(`^([A-Z]+)`);

    auto results = str.matchFirst(r);
    return typeMap.get(results[1], SqliteType.NULL);
}

struct Column
{
	string name;
	SqliteType type;
}
