module sd.type.Matrix;

import d2sqlite3;
import sd.type.Column;

struct Matrix
{
    Column[] columns;
    Row[] rows;

    void clear()
    {
        columns = null;
        rows = null;
    }

    void appendRow(Row row)
    {
        rows ~= row;
    }

    void resize(Row row)
    {
        import std.algorithm : map;

        columns = new Column[row.length];
        foreach(i; 0 .. row.length)
        {
            columns[i] = Column(row.columnName(i), row.columnType(i));
        }
    }


}
