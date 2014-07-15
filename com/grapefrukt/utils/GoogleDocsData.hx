package com.grapefrukt.utils;
import haxe.Timer;
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
	public var data(default, null):Array<T>;
	private var remotePath(get, never):String;
	private var localPath(get, never):String;
	
	private var onComplete:Void->Void;
	
	public function new(documentId:String, onComplete:Void->Void) {
		this.documentId = documentId;
		this.onComplete = onComplete;
		
		// a delay is needed here because local files load immediately with openfl leaving no time to setup other stuff
		Timer.delay(loadCached, 10);
		loadRemote();
	}
	
	private function loadCached() {
		var loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, handleLoadLocalComplete);
		loader.load(new URLRequest(localPath));
	}
	
	public function loadRemote() {
		var loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, handleLoadRemoteComplete);
		loader.load(new URLRequest(remotePath));
	}
	
	private function handleLoadLocalComplete(e:Event):Void {
		var loader:URLLoader = cast e.target;
		parse(loader.data, true);
		onComplete();
	}
	
	private function handleLoadRemoteComplete(e:Event):Void {
		var loader:URLLoader = cast e.target;
		parse(loader.data, false);
		//cache(loader.data);
		onComplete();
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
					try {
						Reflect.setProperty(instance, labels[i], cols[i]);
					} catch (e:Dynamic) {
						trace('ERROR: failed to set field: ' + labels[i] + ' on ' + instance);
					}
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