package com.grapefrukt.utils;
import haxe.Timer;
import openfl.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.SharedObject;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
@:generic class GoogleDocsData<T:{ function new():Void; }> {

	public var data(default, null):Array<T>;
	public var warnMissingFields:Bool = false;
	
	var documentId:String;
	var gId:String;
	var hash:String;
	var labels:Array<String>;
	var remotePath(get, never):String;
	var localPath(get, never):String;
	var onComplete:Void->Void;
	
	var ignoredFields:Map<String, Bool>;
	
	/**
	 * Loads data from a Google Docs spreadsheet. The document needs to be Shared so that "Anyone with the link" can see. 
	 * @param	documentId	The unique identifier for the document. https://docs.google.com/spreadsheets/d/{THIS_PART}/edit?usp=sharing
	 * @param	onComplete	A function to call when load is complete, may be called twice, one for the local cache and again for the remote
	 * @param	gId			The sheet id, the first sheet seems to always be 0, later ones have custom id's
	 */
	public function new(documentId:String, onComplete:Void->Void, gId:String = "0") {
		this.documentId = documentId;
		this.onComplete = onComplete;
		this.gId = gId;
		
		// a delay is needed here because local files load immediately with openfl leaving no time to setup other stuff
		Timer.delay(loadCached, 10);
		loadRemote();
	}
	
	/**
	 * A list of field names to skip setting on the target class
	 * @param	names
	 */
	public function ignoreFields(names:Array<String>) {
		ignoredFields = new Map();
		for (field in names) ignoredFields.set(field, true);
	}
	
	function loadCached() {
		var data:String = Assets.getText(localPath);
		if (data == null) return;
		parse(data, true);
		onComplete();
	}
	
	public function loadRemote() {
		#if (android || flash)
			
		#else
			var loader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, handleLoadRemoteComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, handleLoadRemoteError);
			#if flash
				loader.addEventListener(IOErrorEvent.NETWORK_ERROR, handleLoadRemoteError);
			#end
			loader.load(new URLRequest(remotePath));
		#end
	}
	
	function handleLoadRemoteError(e:Event) {
		trace("ERROR: loading remote data failed");
	}
	
	function handleLoadRemoteComplete(e:Event) {
		var loader:URLLoader = cast e.target;
		
		if (loader.data.indexOf('<H1>Moved Temporarily</H1>') != -1) {
			trace('ERROR: document loaded but has redirect. permissions are probably not set correctly (needs to be shared with public)');
			return;
		}
		
		// remote data was identical to local cache, bail
		if (getHash(loader.data) == hash) return;
		
		parse(loader.data, false);
		cache(loader.data);
		onComplete();
	}
	
	function cache(csv:String) {
		#if desktop
			try {
				if (!FileSystem.exists('cache')) FileSystem.createDirectory('cache');
				File.write(localPath);
				File.saveContent(localPath, csv);
			} catch (e:Dynamic) {
				trace("ERROR: failed to write file, permissions may be borked");
			}
		#else 
			var s = SharedObject.getLocal(documentId, '/');
			s.setProperty('data', csv);
			s.flush();			
		#end
	}
	
	function parse(csv:String, local:Bool) {
		hash = getHash(csv);
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
					// if this is an ignored field, skip it
					if (ignoredFields != null && ignoredFields.exists(labels[i])) continue;
					
					try {
						set(instance, labels[i], cols[i]);
					} catch (e:Dynamic) {
						if (warnMissingFields) trace('ERROR: failed to set field: ' + labels[i] + ' on ' + instance);
					}
				}
				data.push(instance);
			}
		}
		trace('parsed ' + data.length + ' rows from ' + (local ? 'local filesystem' : 'google docs'));
	}
	
	function set(instance:T, field:String, value:Dynamic) {
		Reflect.setProperty(instance, field, value);
	}
	
	function getHash(data:String) {
		return haxe.crypto.Md5.encode(data);
	}
	
	function get_localPath():String {
		return 'cache/$documentId.csv';
	}
	
	function get_remotePath():String {
		return 'https://docs.google.com/spreadsheets/d/' + documentId + '/export?format=csv&id=' + documentId + '&gid=' + gId;
	}
}