module sd.sql.util;

import d2sqlite3;

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
