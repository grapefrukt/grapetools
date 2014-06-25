package com.grapefrukt.utils;
import openfl.events.Event;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
@:generic class GoogleDocsData<T:{ function new():Void; }> {

	private var documentId:String;
	private var labels:Array<String>;
	private var data:Array<T>;
	private var remotePath(get, never):String;
	private var localPath(get, never):String;
	
	public function new(documentId:String) {
		this.documentId = documentId;
		
		reload(true);
		reload(false);
	}
	
	public function reload(local:Bool = false) {
		var loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, local ? handleLoadLocalComplete : handleLoadRemoteComplete);
		loader.load(new URLRequest(local ? localPath : remotePath));
	}
	
	private function handleLoadLocalComplete(e:Event):Void {
		var loader:URLLoader = cast e.target;
		parse(loader.data, true);
	}
	
	private function handleLoadRemoteComplete(e:Event):Void {
		var loader:URLLoader = cast e.target;
		parse(loader.data, false);
		cache(loader.data);
	}
	
	private function cache(csv:String) {
		#if cpp
			if (!FileSystem.exists('cache')) FileSystem.createDirectory('cache');
			File.write(localPath);
			File.saveContent(localPath, csv);
		#end
	}
	
	private function parse(csv:String, local:Bool) {
		labels = null;
		data = [];
		var rows = csv.split('\n');
		for (row in rows) {
			var cols = row.split(',');
			if (labels == null) {
				labels = cols;
			} else {
				var instance = new T();
				for (i in 0 ... cols.length) {
					Reflect.setProperty(instance, labels[i], cols[i]);
				}
				data.push(instance);
			}
		}
		trace('parsed ' + data.length + ' rows from ' + (local ? 'local filesystem' : 'google docs'));
	}
	
	private function get_localPath():String {
		return 'cache/' + documentId + '.csv';
	}
	
	private function get_remotePath():String {
		return 'https://docs.google.com/spreadsheets/d/' + documentId + '/export?format=csv&id=' + documentId + '&gid=0';
	}
}