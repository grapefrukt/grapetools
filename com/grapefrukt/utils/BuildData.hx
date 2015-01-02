package com.grapefrukt.utils;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class BuildData {
	
	macro static public function timestamp() {
		var now_str = Date.now().toString();
		return macro $v { now_str };
	}
	
	macro static public function tag() {
		var process = new sys.io.Process('git', ['describe', '--tags', '--always']);
		var output = '';
		
		// try to read the stdout, this crashes if there's nothing to read, hence the try/catch
		try {
			output = process.stdout.readLine();
		} catch (e:Dynamic) {
			// call failed, not much to do about it
		}
		
		// finally, close the process, it should be closed already, but just to make sure
		process.close();
		
		return macro $v { output };
	}
	
	macro static public function export() {
		var f = sys.io.File.write('build.json');
		f.writeString('{ "date" : "${timestamp()}", "tag" : "${tag()}" }');
		f.close();
		
		return macro null;
	}
	
}