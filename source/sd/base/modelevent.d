module sd.base.modelevent;

public import std.traits : Parameters;

mixin template ModelEvent(string eventID, T)
{
	T[] handlers;
	
	void fire(Parameters!T args)
	{
		import std.algorithm : each;

		handlers.each!(h => h(args));
	}

	ulong register(T handler){
		handlers ~= handler;
		return handlers.length-1;
	}
}

unittest{
	import std.stdio;
	class TestEmitter{
		mixin ModelEvent!("testEvent", void delegate()) test;
		mixin ModelEvent!("db:close", void delegate(string)) onClose;
	}

	TestEmitter emitter = new TestEmitter();
	emitter.onClose.register((db){ writeln("Closing database ", db, ": Received from callback 1");});
	emitter.onClose.register((db){ writeln("Received from callback 2"); });
	emitter.onClose("test.db");
}
