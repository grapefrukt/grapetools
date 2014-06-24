package com.grapefrukt.utils;
import openfl.Lib;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class Perf {
	
	private static var categories:Map<String, Category>;
	public static var numEntries(default, null):Int;
	public static var total:Category;
	
	public static function init(numEntries:Int = 17 * 60) {
		Perf.numEntries = numEntries;
		total = new Category();
		categories = new Map();
	}
	
	public static function begin(name:String) {
		get(name).begin();
	}
	
	public static function end(name:String) {
		get(name).end();
	}
	
	public static function getAverage(name:String) {
		return get(name).getAverage();
	}
	
	static public function tick() {
		total.end();
		total.begin();
	}
	
	private inline static function get(name):Category {
		var category = categories.get(name);
		if (category == null) {
			category = new Category();
			categories.set(name, category);
		}
		return category;
	}
}

private class Category {
	public var sum:Float = 0;
	public var entries:Array<Float>;
	public var index:Int;
	public var began:Float = 0;
	
	public function new() {
		entries = [];
		for (i in 0 ... Perf.numEntries) entries.push(0);
	}
	
	public function begin() {
		began = Lib.getTimer();
	}
	
	public function end() {
		var duration = Lib.getTimer() - began;
		
		// remove the oldest entry from the sum
		sum -= entries[index % Perf.numEntries];
		
		sum += duration;
		entries[index % Perf.numEntries] = duration;
		
		index++;
	}
	
	public function getAverage() {
		return (sum / Perf.numEntries);
	}
}