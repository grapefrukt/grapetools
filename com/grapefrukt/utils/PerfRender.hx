package com.grapefrukt.utils;
import openfl.display.Shape;
import openfl.events.Event;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class PerfRender extends Shape {
	
	private var categories:Array<String>;
	private var colors:Array<Int>;
	private var pixelsPerMS:Float;
	private var targetFrameTime:Float = 16.667;
	private var barHeight:Float = 8;

	public function new(categories:Array<String>, pixelsPerMS:Float = 50, ?colors:Array<Int>) {
		super();
		this.categories = categories;
		this.pixelsPerMS = pixelsPerMS;
		this.colors = colors;
		
		if (this.colors == null) {
			this.colors = [0x75b8e5, 0x7f1345, 0xe8d93e, 0x2b1682];
		}
		
		addEventListener(Event.ENTER_FRAME, handleEnterFrame);
	}
	
	private function handleEnterFrame(e:Event):Void {
		graphics.clear();
		var lastX = 0.0;
		var i = 0;
		for (category in categories) {
			var avg = Perf.getAverage(category);
			graphics.beginFill(colors[i % (colors.length)]);
			graphics.drawRect(lastX, 0, avg * pixelsPerMS, barHeight);
			lastX += avg * pixelsPerMS;
			
			i++;
		}
		
		graphics.beginFill(0);
		graphics.drawRect(Std.int(pixelsPerMS * targetFrameTime - 1), 0, 2, barHeight + 2);
	}
	
}