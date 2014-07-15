/**
 * @author Joshua Granick
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */

package com.grapefrukt.utils.easing;

class Quad {
	
	public static function easeIn(k:Float):Float {
		return k * k;
	}
	
	public static function easeInOut(k:Float):Float {
		if ((k *= 2) < 1) {
			return 1 / 2 * k * k;
		}
		return -1 / 2 * ((k - 1) * (k - 3) - 1);
	}
	
	public static function easeOut(k:Float):Float {
		return -k * (k - 2);
	}
	
}