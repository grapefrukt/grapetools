package com.grapefrukt.utils;
import flash.events.EventDispatcher;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class Cooldown {

	/**
	 * The time it takes for the cooldown to trigger once reset
	 */
	public var duration:Float;
	
	/**
	 * The current time remaining to completion
	 */
	public var cooldown(default, null):Float;
	
	/**
	 * If true, the cooldown starts over automatically once completed
	 */
	public var autoReset:Bool;
	
	public var isCompleted(get, never):Bool;
	
	/**
	 * Gets the progress of the cooldown
	 * @return 1 is completed, 0 is not started
	 */
	public var ratio(get, set):Float;
	
	/**
	 * @return 0 is completed, 1 is not started
	 */
	public var ratioInverse(get, never):Float;
	
	private var _onComplete:Void->Void;
	
	public function new(duration:Float, autoReset:Bool = false, onComplete:Void->Void = null) {
		//super();
		this.duration = duration;
		this.cooldown = duration;
		this.autoReset = autoReset;
		_onComplete = onComplete;
	}
	
	public function update(timeDelta:Float):Void {
		if (cooldown > 0 && cooldown - timeDelta <= 0) {
			//dispatchEvent(new CooldownEvent(CooldownEvent.COMPLETE, this));
			if (_onComplete != null) _onComplete();
			if (autoReset) reset();
		}
		cooldown -= timeDelta;
	}
	
	/**
	 * Sets the cooldown to the duration
	 */
	public function reset(newDuration:Float = -1) {
		if (newDuration >= 0) duration = newDuration;
		cooldown = duration;
		//dispatchEvent(new CooldownEvent(CooldownEvent.RESET, this));
	}
	
	/**
	 * Prematurely ends the cooldown, will call the callback (and auto-reset if that is enabled)
	 */
	public function complete() {
		cooldown = 0;
		update(.1);
	}
	
	private function get_ratio():Float {
		if (cooldown <= 0) return 1;
		return 1 - cooldown / duration;
	}
	
	private function set_ratio(value:Float):Float {
		if (value > 1) value = 1;
		if (value < 0) value = 0;
		cooldown = duration * (1 - value);
		if (value == 1) complete;
		
		return get_ratio();
	}
	
	private function get_ratioInverse():Float {
		return 1 - get_ratio();
	}
	
	private function get_isCompleted() {
		return get_ratio() >= 1;
	}
}