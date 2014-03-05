package com.grapefrukt.utils;

import flash.Lib;

/**
 * ...
 * @author Martin Jonasson (m@grapefrukt.com)
 */
class Timestep {
	
	public var maxSpeed				:Float;
	public var gameSpeed			:Float;
	public var smoothing(default, set):Float;
	
	public var targetFrametime(default, null):Float;
	
	private var _real_speed			:Float;
	private var _last_frame_time	:Float;
	private var _delta				:Float;
	
	public var timeDelta(get, never):Float;
	public var realtimeDelta(get, never):Float;
	
	/**
	 * Initializes the timestepper
	 * @param	fps			The target framerate you wish to maintain
	 * @param	gameSpeed	The game's speed, useful for slowdown effects or general speed tweaking. 1 = 100% speed.
	 * @param	maxSpeed	The maximum size of a timeDelta, steps will not be bigger than this
	 * @param	smoothing	How much to smooth the step size across ticks, 1 gives old value full priority (value will never change), 0 means no smoothing, so new value will be used.
	 */
	public function new(fps:Int = 60, gameSpeed:Float = 1.0, maxSpeed:Float = 3.0, smoothing:Float = 0.5) {
		targetFrametime = 1000 / fps;
		_last_frame_time = 0;
		_delta = 1;
		this.smoothing = smoothing;
		this.gameSpeed = gameSpeed;
		this.maxSpeed = maxSpeed;
	}
	
	/**
	 * Call this function every frame to get a updated timeDelta
	 * @return	timeDelta
	 */
	public function tick():Float {
		_real_speed = (Lib.getTimer() - _last_frame_time) / targetFrametime;
		_last_frame_time = Lib.getTimer();
		
		if (_real_speed > maxSpeed) _real_speed = maxSpeed;
		
		_delta -= (_delta - _real_speed) * (1 - smoothing);
		
		return _delta * gameSpeed;
	}
	
	inline function get_timeDelta():Float { return _delta * gameSpeed; }
	inline function get_realtimeDelta():Float { return _delta; }
	
	public function set_smoothing(value:Float):Float {
		if (value > 1) value = 1;
		if (value < 0) value = 0;
		smoothing = value;
		return smoothing;
	}
	
}