package com.grapefrukt.utils;

import flash.Lib;
/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class Freezer {
	
	private static var frozeAt:Int;
	
	public static var frozenSpeed:Float = .05;
	public static var fadeIn:Int = 0;
	public static var fadeOut:Int = 0; // 16 * 10;
	public static var duration:Int = 16 * 30;
	
	public static var multiplier(get, never):Float;
	
	public static function freeze() {
		frozeAt = Lib.getTimer();
	}
	
	private static function get_multiplier():Float {
		var time:Int = Lib.getTimer() - frozeAt;
		
		if (time < fadeIn) return lerp(1, frozenSpeed, time / fadeIn);		
		time -= fadeIn;
		
		if (time < duration) return frozenSpeed;
		time -= duration;
		
		if (time < fadeOut) return lerp(frozenSpeed, 1, time / fadeOut);
		
		return 1;
	}
	
	private static inline function lerp(start:Float, end:Float, f:Float):Float {
		return start + (end - start) * f;
	}
	
}