package com.grapefrukt.utils;
import flash.display.Shape;
import flash.events.Event;
import flash.Lib;
import motion.Actuate;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class Flasher {

	private var canvas:Shape;
	public var offColor:Int;
	
	public function new(canvas:Shape, offColor:Int) {
		this.offColor = offColor;
		this.canvas = canvas;
		Lib.current.stage.addEventListener(Event.RESIZE, handleResize);
		handleResize(null);
	}
	
	private function handleResize(e:Event):Void {
		canvas.graphics.clear();
		canvas.graphics.beginFill(offColor);
		canvas.graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
	}
	
	public function flash(color:Int, duration:Float) {
		Actuate.transform(canvas, .1, true).color(color, 1, 1);
		Actuate.transform(canvas, .5, false).color(offColor, 1, 1).delay(duration);
	}
	
}