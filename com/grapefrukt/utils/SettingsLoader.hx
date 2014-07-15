package com.grapefrukt.utils;
import haxe.rtti.Meta;
import openfl.errors.Error;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.Lib;
import openfl.net.URLLoader;
import openfl.net.URLRequest;
import openfl.Assets;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */

class SettingsLoader extends EventDispatcher {
		
	private var loader:URLLoader;
	private var url:String;
	public var target(default, null):Dynamic;
	
	public function new(url:String, target:Dynamic = null) {
		super();
		this.target = target;
		loader = new URLLoader();
		loader.addEventListener(Event.COMPLETE, handleLoadComplete);
		loader.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
		reload(url);
	}
	
	public function reload(url:String = "", target:Dynamic = null):Void {
		if (url != "") this.url = url;
		if (target != null) this.target = target;
		
		#if (bakeassets)
			parse(Assets.getText(this.url));
			dispatchEvent(new Event(Event.COMPLETE));
		#else
			loader.load(new URLRequest(this.url));
		#end
	}
	
	private function handleSecurityError(e:SecurityErrorEvent):Void {
		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "security error loading settings: " + e.text));
	}
	
	private function handleIOError(e:IOErrorEvent):Void {
		dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "io error loading settings: " + e.text));
	}

	private function handleLoadComplete(e:Event):Void {
		parse(loader.data);
		
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	#if false
	public function export() {
		var name = url.substr(url.lastIndexOf("/") + 1);
		var fields = Type.getClassFields(target);
		var metadata = Meta.getStatics(target);
		
		fields.sort(_sort);
		
		var newData = "";
		
		var widest = 0;
		for (field in fields) if (field.length > widest) widest = field.length;
		
		var group = "";
		
		for (field in fields) {
			var uc = field.toUpperCase();
			if (uc != field) continue;
			
			switch(Type.typeof(Reflect.field(target, field))) {
				case ValueType.TFloat : // nothing
				case ValueType.TInt : // nothing
				case ValueType.TBool : // nothing
				default : continue;
			}
			
			var meta = Reflect.field(metadata, field);
			
			if (meta != null) if (Reflect.hasField(meta, "hidden")) continue;
			
			var newgroup = getGroupName(field);
			
			if (group != "" && newgroup != group) newData += "\n";
			group = newgroup;
			
			newData += StringTools.rpad(field, " ", widest + 3) + Reflect.field(target, field) + "\n";
		}
		
		newData = newData.substr(0, newData.length - 1);
		
		#if flash
			var f = new flash.net.FileReference();
			f.save(newData, name);
		#elseif cpp
			 var f = sys.io.File.write(url);
			f.writeString(newData);
			f.close();
		#end
	}
	#end
	
	private function getGroupName(name:String):String {
		return name.substr(0, name.indexOf("_"));
	}
	
	private function _sort(s1:String, s2:String):Int {
		if (s1 < s2) return -1;
		if (s1 > s2) return 1;
		return 0;
	}

	private function parse(data:String){
		var r = ~/^(?<!#)(\w+)\s+(.*?)\s*(#.*)?$/m;
		
		while (r.match(data)) {
			setValue(r.matched(1), r.matched(2));
			data = r.matchedRight();
		}
	}
	
	private function setValue(name:String, value:Dynamic):Void {
		if (!Reflect.hasField(target, name)) {
			trace("Can't set value: " + name + ". No such value exists");
			return;
		}
		
		if (Std.string(value) == "true") {
			Reflect.setField(target, name, true);
		} else if(Std.string(value) == "false") {
			Reflect.setField(target, name, false);
		} else {
			Reflect.setField(target, name, value);
			//if (Std.parseInt(value) != Reflect.field(target, name) && Std.parseFloat(value) != Reflect.field(target, name)) throw new Error("Failed setting value! " + name + ". Tried setting: " + value + " is actually: " + Reflect.field(target, name));
		}
	}

}