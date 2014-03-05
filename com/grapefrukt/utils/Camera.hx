package com.grapefrukt.utils;
import flash.display.Sprite;
import flash.Lib;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class Camera {

	private var container:Sprite;
	private var panX:Float = 0;
	private var panY:Float = 0;
	private var deltaZ:Float = 0;
	
	public var shakeX:Float = 0;
	public var shakeY:Float = 0;
	
	public function new(container:Sprite) {
		this.container = container;
	}
	
	public function update(delta:Float) {
		var r = container.getBounds(container);
		r.inflate(200, 200);
		
		var ratioX = r.width / Lib.current.stage.stageWidth;
		var ratioY = r.height / Lib.current.stage.stageHeight;
		
		deltaZ -= deltaZ * 0.03 * delta;
		var changeZ = ((ratioX > ratioY ? 1 / ratioX : 1 / ratioY) - container.scaleX) * 0.003 * delta;
		if (changeZ > 0) changeZ *= .05;
		deltaZ += changeZ;
		
		container.scaleX += deltaZ;
		container.scaleY = container.scaleX;
		
		panX += (r.x - panX) * 0.03 * delta;
		panY += (r.y - panY) * 0.03 * delta;
		
		container.x = Lib.current.stage.stageWidth / 2 - (panX + r.width  / 2) * container.scaleX + shakeX;
		container.y = Lib.current.stage.stageHeight / 2 - (panY + r.height / 2) * container.scaleY + shakeY;
		
	}
	
	public function reset() {
		panX = panY = 0;
		deltaZ = 0;
		container.scaleX = container.scaleY = .01;
	}
	
}