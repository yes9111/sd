module sd.type.matrix;

import d2sqlite3 : CachedResults, ResultRange, cached;
import sd.type.column;

class Matrix
{
	const Column[] columns;
	CachedResults results;

	this(ResultRange results)
	{
		import sd.sql.util : getQueryColumns;

		this.columns = results.getQueryColumns();
		this.results = results.cached;
	}

	ulong getNCols() const
	{
		return columns.length;
	}
}
