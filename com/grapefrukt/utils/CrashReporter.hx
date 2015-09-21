package com.grapefrukt.utils;

#if cpp
import haxe.CallStack;
import haxe.CallStack.StackItem;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
#end

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
 
using StringTools;

class CrashReporter {
	

	#if cpp
	
	static private var pathPrefix:String;
	
	public static function init(pathPrefix:String = '') {
		CrashReporter.pathPrefix = pathPrefix;
		// replace all back slashes with forward slashes
		CrashReporter.pathPrefix = CrashReporter.pathPrefix.replace('\\', '/');
		// remove trailing slash if present
		if (CrashReporter.pathPrefix.endsWith('/')) CrashReporter.pathPrefix = pathPrefix.substr(0, pathPrefix.length - 1);
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onErrorEvent); 
	}
	
	static function onErrorEvent(e:UncaughtErrorEvent) {
		var error = e.error;
		var time = Date.now().toString();
		var data = '${e.error}\n$time\nBuilt on: ${BuildData.timestamp}\nGit tag: ${BuildData.tag}';
		
		var stack:Array<StackItem> = CallStack.exceptionStack();
		stack.reverse();
		
		var index = 0;
		for (item in stack) {
			var row = printStackItem(item, error, index == 0);
			if (index == 0 && row.indexOf('display/Stage.hx') > -1) continue;
			data += row + '\n';
			index++;
		}
		
		trace(data);
		
		#if desktop
			var f = sys.io.File.write('crash_report.txt');
			f.writeString(data);
			f.close();
		#end
	}
	
	static function printStackItem(itm:StackItem, error:String = '', isFirst:Bool = false) {
		var str:String = '';
		switch( itm ) {
			case CFunction:
				str = 'a C function';
			case Module(m):
				str = 'module $m';
			case FilePos(itm,file,line):
				if (itm == null) return '';
				if (isFirst ) str += '$pathPrefix/$file:$line: characters 0-1 : $error';
				else str += '\t$pathPrefix/$file:$line';
				//str += printStackItem(itm);
			case Method(cname,meth):
				str += '$cname.$meth';
			case LocalFunction(n):
				str += 'local function #$n';
		}
		return str;
	}
	
	#else 
		public static function init(pathPrefix:String = '') {
			// non cpp platforms are not supported
		}
	#end
}