/**
 * @author Martin Jonasson
 * @author Joshua Granick
 * @author Zeh Fernando, Nate Chatellier
 * @author Robert Penner / http://www.robertpenner.com/easing_terms_of_use.html
 */


package com.grapefrukt.utils.easing;

class Back {
	
	private static inline var s:Float = 1.70158;
	
	public function easeIn(k:Float):Float {
		return k * k * ((s + 1) * k - s);
	}

	public function easeInOut(k:Float):Float {
		if ((k /= 0.5) < 1) return 0.5 * (k * k * (((s *= (1.525)) + 1) * k - s));
		return 0.5 * ((k -= 2) * k * (((s *= (1.525)) + 1) * k + s) + 2);
	}

	public function easeOut(k:Float):Float {
		return ((k = k - 1) * k * ((s + 1) * k + s) + 1);
	}

}