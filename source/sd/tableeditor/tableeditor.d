module sd.tableeditor.tableeditor;

import sd.type.database : Database;
import sd.tableeditor.model;
import sd.tableeditor.view;
import sd.type.table;

class TableEditor
{
	public this(in Database database, string table)
	{
		auto model = new TableModel(database, table);
		auto structureEditor = new StructureEditor(model);
		structureEditor.showAll();
	}

}
