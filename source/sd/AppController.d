module sd.AppController;

import std.stdio, std.file, std.path, std.typecons;

import sd.AppModel;
import sd.data.Table;

class AppController
{
private:
	AppModel 	model;
public:
	this(AppModel model)
	{
		this.model = model;
	}

	Nullable!Table openDB(string path)
	{
		try
		{
			assert(path.exists);
			return model.addDB(path);
		}
		catch(Exception e)
		{
			writeln("Error opening DB: ", e.toString());
			return Nullable!Table.init;
		}
	}

	void closeDB(string db)
	{
		model.removeDB(db);
	}
}
