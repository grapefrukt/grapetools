package com.grapefrukt.utils;
import com.grapefrukt.games.versus.Settings;
import com.grapefrukt.utils.events.CooldownEvent;
import nme.events.EventDispatcher;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class Cooldown extends EventDispatcher {

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
	
	public var isCompleted(get_isCompleted, never):Bool;
	
	private var _onComplete:Void->Void;
	
	public function new(duration:Float, autoReset:Bool = false, onComplete:Void->Void = null) {
		super();
		this.duration = duration;
		this.cooldown = duration;
		this.autoReset = autoReset;
		_onComplete = onComplete;
	}
	
	public function update(timeDelta:Float):Void {
		timeDelta /= Settings.FPS;
		if (cooldown > 0 && cooldown - timeDelta <= 0) {
			dispatchEvent(new CooldownEvent(CooldownEvent.COMPLETE, this));
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
		dispatchEvent(new CooldownEvent(CooldownEvent.RESET, this));
	}
	
	/**
	 * Prematurely ends the cooldown, will call the callback (and auto-reset if that is enabled)
	 */
	public function complete() {
		cooldown = 0;
		update(.1);
	}
	
	/**
	 * Gets the progress of the cooldown
	 * @return 0 is completed, 1 is not started
	 */
	public function getProgress():Float {
		if (cooldown <= 0) return 0;
		return cooldown / duration;
	}
	
	/**
	 * @return 1 is completed, 0 is not started
	 */
	public function getProgressReverse():Float {
		return 1 - getProgress();
	}
	
	private function get_isCompleted() {
		return getProgress() == 0;
	}
}