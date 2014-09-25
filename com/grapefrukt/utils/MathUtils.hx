package com.grapefrukt.utils;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class MathUtils {

	public static inline function lerp(from:Float, to:Float, progress:Float) {
		return from + (to - from) * progress;
	}
	
	public static inline function lerpWrap(from:Float, to:Float, progress:Float, wrapsAt:Float = 1) {
		var change = (to - from);
		if (change > wrapsAt / 2) change -= wrapsAt;
		if (change < -wrapsAt / 2) change += wrapsAt;
		return from + change * progress;
	}
	
	public static function clamp(value:Float, max:Float = 1, min:Float = 0) {
		if (value > max) return max;
		if (value < min) return min;
		return value;
	}
	
}