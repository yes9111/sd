module sd.dbbrowser.controller;

import sd.dbbrowser.model;
import sd.type.table;

package final class DBBrowserController
{
private:
	DBBrowserModel model;
public:
	this(DBBrowserModel model)
	{
		this.model = model;
	}

	void openDB(string path)
	{
		try
		{
			import std.file : exists;
			if (path.exists){
				model.addDB(path);
			}
		}
		catch (Exception e)
		{
			import std.experimental.logger : errorf;
			errorf("Error opening DB: ", e.toString());
		}
	}

	void closeDB(string db)
	{
		model.removeDB(db);
	}

	void runSQL(string db, string sql)
	{
		model.runSQL(db, sql);
	}

	DBBrowserModel getModel()
	{
		return model;
	}
}
