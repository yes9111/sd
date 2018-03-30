module sd.type.Matrix;

import d2sqlite3;
import sd.type.Column;

struct Matrix
{
    Column[] columns;
	CachedResults results;

    void clear()
    {
        columns = null;
		results = results.init;
    }

	void set(Column[] columns, CachedResults results)
	{
		if(results.length == 0){
			clear();
			return;
		}

		this.columns = columns;
		this.results = results;
	}

	ulong getNCols() const
	{
		return columns.length;
	}
}
