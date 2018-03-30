module sd.TableEditor.TableEditor;

import sd.TableEditor.Model;
import sd.TableEditor.View;

import sd.type.Table;

class TableEditor
{
	public this(in Database database, string table)
	{
		auto model = new TableModel(database, table);
		/*
		auto view = new View(model);
		*/
		auto structureEditor = new StructureEditor(model);
		structureEditor.showAll();
	}

}
