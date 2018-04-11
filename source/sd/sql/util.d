module sd.sql.util;

import d2sqlite3;
import gobject.Value;

import sd.type.Column;

Column[] getQueryColumns(Database db, string query)
{
	auto results = db.execute(query);
	if(results.empty)
	{
		return null;
	}

	auto sampleRow = results.front;
	Column[] cols;
	cols.length = sampleRow.length;
	foreach(i; 0 .. sampleRow.length)
	{
		cols[i] = Column(sampleRow.columnName(i), sampleRow.columnType(i));
	}
	return cols;
}

GType toGType(SqliteType type)
{
	switch(type)
	{
		case SqliteType.INTEGER: return GType.INT;
		case SqliteType.TEXT: return GType.STRING;
		case SqliteType.FLOAT: return GType.FLOAT;
		case SqliteType.BLOB: return GType.STRING;
		case SqliteType.NULL: return GType.NONE;
		default: return GType.INVALID;
	}
}

Value toGValue(ColumnData field)
{
	switch(field.type)
	{
		case SqliteType.INTEGER:
			return new Value(field.as!int);
		case SqliteType.TEXT:
			return new Value(field.as!string);
		case SqliteType.FLOAT:
			return new Value(field.as!float);
		case SqliteType.BLOB:
			return new Value(field.as!string);
		case SqliteType.NULL:
			return new Value("NULL");
			//return null;
		default:
			throw new Exception("Unknown SQLType.");
	}

}
