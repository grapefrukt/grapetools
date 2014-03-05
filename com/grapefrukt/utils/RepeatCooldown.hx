package com.grapefrukt.utils;
import com.grapefrukt.utils.events.CooldownEvent;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class RepeatCooldown extends Cooldown {

	public var repeatCount:Int;
	public var tickCount:Int;
	private var _onTick:Void->Void;
	private var __onComplete:Void->Void;
	
	public function new(duration:Float, repeatCount:Int, onTick:Void->Void = null, onComplete:Void->Void = null) {
		super(duration, false, handleComplete);
		this.repeatCount = repeatCount;
		this.tickCount = 0;
		this._onTick = onTick;
		this.__onComplete = onComplete;
	}
	
	private function handleComplete() {
		tickCount++;
		
		if (_onTick != null) {
			dispatchEvent(new CooldownEvent(CooldownEvent.TICK, this));
			_onTick();
		}
		
		if (tickCount >= repeatCount) {
			dispatchEvent(new CooldownEvent(CooldownEvent.COMPLETE, this));
			if (__onComplete != null) __onComplete();
		} else {
			super.reset();
		}
	}
	
	override public function reset(newDuration:Float = -1) {
		super.reset(newDuration);
		tickCount = 0;
	}
	
}