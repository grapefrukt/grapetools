package com.grapefrukt.utils;
import haxe.Http;
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr;

#if macro
import sys.io.File;
import sys.io.Process;
#end

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */

using StringTools;
 
class BuildData {
	
	#if windows
	static public inline var platform:String = 'windows';
	#elseif osx
	static public inline var platform:String = 'osx';
	#elseif linux
	static public inline var platform:String = 'linux';
	#elseif flash
	static public inline var platform:String = 'flash';
	#elseif android
	static public inline var platform:String = 'android';
	#elseif ios
	static public inline var platform:String = 'ios';
	#else
	static public inline var platform:String = 'unknown';
	#end
	
	static public var tag(default, null):String = _macro_tag();
	static public var timestamp(default, null):String = _macro_timestamp();
	
	public static inline var REMOTE_FAIL	:Int = -1;
	public static inline var REMOTE_UNKNOWN	:Int = 0;
	public static inline var REMOTE_SAME	:Int = 1;
	public static inline var REMOTE_OLDER	:Int = 2;
	public static inline var REMOTE_NEWER	:Int = 3;
	
	static inline var TIME_FUZZ:Int = 60 * 1000; // adds a one minute margin of error to build times
	
	public static var remoteState(default, null):Int = REMOTE_UNKNOWN;
	static var onRemoteDataCallback:Int->Void;
	static var url:String;
	
	macro static function _macro_timestamp() {
		var now_str = Date.now().toString();
		return macro $v { now_str };
	}
	
	macro static function _macro_tag() {
		var process = new Process('git', ['describe', '--tags', '--always']);
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
	
	macro static public function export(data:Map<String, String> = null) {
		if (data == null) data = new Map();
		
		// reads in build data generated earlier in the build
		try {
			var f = File.read('build.json');
			var s = f.readLine();
			var d = Json.parse(s);
			for (field in Reflect.fields(d)) data.set(field, Reflect.field(d, field));
			f.close();
		} catch (e:Dynamic) {
			// no build.json was present or parsing failed
		}
		
		data.set('date', timestamp);
		data.set('tag', tag);
		
		var f = File.write('build.json');
		f.writeString(Json.stringify(data, null, '\t'));
		f.close();
		
		return macro null;
	}
	
	static public function check(url:String, onRemoteDataCallback:Int->Void) {
		BuildData.onRemoteDataCallback = onRemoteDataCallback;
		BuildData.url = url.replace("$platform", platform);
		
		#if cpp
			cpp.vm.Thread.create(request);
		#else
			request();
		#end
	}
	
	static function request() {
		var http:Http = new Http(url);
		http.onData = onData;
		http.onError = onError;
		http.request();	
	}
	
	static function onData(data:String) {
		try {
			var j = Json.parse(data);
			var localTimestamp = Date.fromString(timestamp).getTime();
			var remoteTimestamp = Date.fromString(j.date).getTime();
			var diff = localTimestamp - remoteTimestamp;
			
			if (Math.abs(diff) < TIME_FUZZ) {
				remoteState = REMOTE_SAME;
			} else if (diff > 0) {
				remoteState = REMOTE_OLDER;
			} else {
				remoteState = REMOTE_NEWER;
			}
			
		} catch (e:Dynamic) {
			remoteState = REMOTE_FAIL;
		}
		
		onRemoteDataCallback(remoteState);
	}
	
	static function onError(str:String) {
		remoteState = REMOTE_FAIL;
		onRemoteDataCallback(remoteState);
	}
	
}