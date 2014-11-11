/**
 * @author Joshua Granick
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */

package com.grapefrukt.utils.easing;	
	
class Sine {
		
	public static function easeIn(k:Float):Float {
		return 1 - Math.cos(k * (Math.PI / 2));
	}
	
	public static function easeOut(k:Float):Float {
		return Math.sin(k * (Math.PI / 2));
	}	
	
	public static function easeInOut(k:Float):Float {
		return - (Math.cos(Math.PI * k) - 1) / 2;
	}
	
}