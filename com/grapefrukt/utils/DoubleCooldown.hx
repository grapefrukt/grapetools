package com.grapefrukt.utils;
import com.grapefrukt.utils.Cooldown;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class DoubleCooldown {

	public var first(default, null):Cooldown;
	public var second(default, null):Cooldown;
	
	public var inFirst(get, never):Bool;
	public var inSecond(get, never):Bool;
	public var phaseComplete(get, never):Bool;
	
	private var current:Cooldown;
	
	public var autoTogglePhase:Bool = true;
	
	public function new(firstDuration:Float, secondDuration:Float, onCompleteFirst:Void->Void = null, onCompleteSecond:Void->Void = null) {
		first = new Cooldown(firstDuration, false, onCompleteFirst);
		second = new Cooldown(secondDuration, false, onCompleteSecond);
		
		current = first;
	}
	
	public function update(dt:Float) {
		if (!current.isCompleted) {
			current.update(dt);
		} else if (autoTogglePhase) {
			togglePhase();			
			current.update(dt);
		}
	}
	
	public function togglePhase() {
		current.reset();
		// toggle the current cooldown
		current = (current == first) ? second : first;
	}
	
	public function get_phaseComplete():Bool {
		return current.isCompleted;
	}
	
	private function get_inFirst():Bool {
		return current == first;
	}
	
	private function get_inSecond():Bool {
		return current == second;
	}
	
}