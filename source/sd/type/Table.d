module sd.type.Table;

import sd.type.Column;

struct Database
{
	string path;
	string[] tables;
}

struct Table
{
	string table;
	Column[] columns;
}
