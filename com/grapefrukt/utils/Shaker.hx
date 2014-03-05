package com.grapefrukt.utils;
import com.grapefrukt.utils.Camera;
import flash.geom.Point;
import flash.display.Sprite;
/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class Shaker {
	
	private var _velocity	:Point;
	private var _position	:Point;
	private var _target		:Camera;
	private var _drag		:Float = .1;
	private var _elasticity	:Float = .005;
	
	private static var _shakeDuration:Float;
	
	public function new(target:Camera) {
		_target = target;
		_velocity = new Point();
		_position = new Point();
	}
	
	public function shake(powerX:Float, powerY:Float):Void {
		_velocity.x += powerX;
		_velocity.y += powerY;
		
		if (_velocity.length > 100) _velocity.normalize(100);
	}
	
	public function shakeRandom(power:Float):Void {
		_velocity = Point.polar(power, Math.random() * Math.PI * 2);
	}
	
	public static function shakeDuration(time:Float):Void {
		_shakeDuration = time;
	}
	
	public function update(delta:Float):Void {
		if (_shakeDuration > 0) {
			shakeRandom(3);
			_shakeDuration -= delta;
		}
		
		// apply drag
		_velocity.x -= _velocity.x * _drag * delta;
		_velocity.y -= _velocity.y * _drag * delta;
		
		// attract towards zero
		_velocity.x -= (_position.x) * _elasticity * delta;
		_velocity.y -= (_position.y) * _elasticity * delta;
		
		//_velocity.x += (Math.random() - .5) * _velocity.x * .5;
		//_velocity.y += (Math.random() - .5) * _velocity.y * .5;
		
		// apply velocity to position
		_position.x += (_velocity.x) * delta;
		_position.y += (_velocity.y) * delta;
		
		// apply position to target
		_target.shakeX =_position.x;
		_target.shakeY =_position.y;
	}
	
}
