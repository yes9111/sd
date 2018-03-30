module sd.DBBrowser.Controller;

import std.stdio, std.file, std.path, std.typecons;

import sd.DBBrowser.AppModel;
import sd.type.Table;


class Controller{
private:
	DBModel model;
public:
	this(DBModel model){
		this.model = model;
	}

	void openDB(string path){
		try{
			if(path.exists)
			    model.addDB(path);
		}
		catch(Exception e){
			writeln("Error opening DB: ", e.toString());
		}
	}

	void closeDB(string db){
		model.removeDB(db);
	}

	DBModel getModel(){
		return model;
	}
}
