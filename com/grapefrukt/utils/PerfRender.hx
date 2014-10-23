package com.grapefrukt.utils;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.system.System;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class PerfRender extends Shape {
	
	
	public var pixelsPerMS:Float;
	public var pixelsPerByte:Float = .00005;
	public var barHeight:Float = 8;
	public var categories:Array<String>;
	public var colors:Array<Int>;
	public var targetFrameTime:Float = 1000 / 60;
	
	var maxMem:Int = 0;

	public function new(categories:Array<String>, pixelsPerMS:Float = 50, ?colors:Array<Int>) {
		super();
		this.categories = categories;
		this.pixelsPerMS = pixelsPerMS;
		this.colors = colors;
		
		if (this.colors == null) {
			this.colors = [0xf9fcfc, 0xf68634, 0xf6ea34, 0xf60b73, 0x38cfda];
		}
		
		addEventListener(Event.ENTER_FRAME, handleEnterFrame);
	}
	
	private function handleEnterFrame(e:Event):Void {
		graphics.clear();
		
		graphics.beginFill(colors[0]);
		graphics.drawRect(0, 0, Perf.total.getAverage() * pixelsPerMS, barHeight);
		
		var lastX = 0.0;
		var i = 0;
		for (category in categories) {
			var avg = Perf.getAverage(category);
			graphics.beginFill(colors[(i + 1) % (colors.length)]);
			graphics.drawRect(lastX, 0, avg * pixelsPerMS, barHeight);
			lastX += avg * pixelsPerMS;
			
			i++;
		}
		
		graphics.beginFill(0);
		graphics.drawRect(Std.int(pixelsPerMS * targetFrameTime - 1), -2, 2, barHeight + 4);
	
		if (System.totalMemory > maxMem) maxMem = System.totalMemory;
		
		graphics.beginFill(colors[4]);
		graphics.drawRect(0, barHeight, System.totalMemory * pixelsPerByte, barHeight);
		
		graphics.beginFill(0);
		graphics.drawRect(Std.int(maxMem * pixelsPerByte - 1), barHeight - 2, 2, barHeight + 4);
	}
	
}