package com.grapefrukt.utils;
import com.grapefrukt.utils.Cooldown;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class DoubleCooldown {

	public var first(default, null):Cooldown;
	public var second(default, null):Cooldown;
	
	public function new(firstDuration:Float, secondDuration:Float, onCompleteFirst:Void->Void = null, onCompleteSecond:Void->Void = null) {
		first = new Cooldown(firstDuration, false, onCompleteFirst);
		second = new Cooldown(secondDuration, false, onCompleteSecond);
	}
	
	public function update(dt:Float) {
		if (!first.isCompleted) {
			first.update(dt);
		} else if (!second.isCompleted) {
			second.update(dt);
		} else {
			first.reset();
			second.reset();
			
			first.update(dt);
		}
	}
	
}