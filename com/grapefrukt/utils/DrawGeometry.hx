package com.grapefrukt.utils;
import openfl.display.Graphics;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */
class DrawGeometry{

	/*
	 * This function includes code from by Ric Ewing.
	 * @author 	Zack Jordan
	 */

	static public function drawDonut(
		graphics:Graphics, 
		x:Float, 
		y:Float, 
		radius:Float, 
		innerRadius:Float, 
		color:Int = 0xFF0000, 
		fillAlpha:Float = 1 
	): Void
	{
		var theta:Float = -(45.0 / 180.0) * Math.PI;
		var angle:Float = .0;
		var angleMid:Float;
		var segs:Int = 8;

		graphics.beginFill(color, fillAlpha);
		
		// line 1
		graphics.moveTo(
			x + Math.cos(0) * radius,
			y + Math.sin(0) * radius 
		);
		
		// outer arc
		for (i in 0 ... segs) {
			angle += theta;
			angleMid = angle - (theta / 2);
			var bx = x + Math.cos(angle) * radius;
			var by = y + Math.sin(angle) * radius;
			var cx = x + Math.cos(angleMid) * (radius / Math.cos(theta / 2));
			var cy = y + Math.sin(angleMid) * (radius / Math.cos(theta / 2));
			graphics.curveTo(cx, cy, bx, by);
			//graphics.lineTo(bx, by);
		}
		
		// line 2
		graphics.lineTo(
			x + Math.cos(angle) * innerRadius, 
			y + Math.sin(angle) * innerRadius 
		);
		
		// inner arc
		for (j in 0 ... segs) {
			angle -= theta;
			angleMid = angle + (theta / 2);
			var bx = x + Math.cos(angle) * innerRadius;
			var by = y + Math.sin(angle) * innerRadius;
			var cx = x + Math.cos(angleMid) * (innerRadius / Math.cos(theta / 2));
			var cy = y + Math.sin(angleMid) * (innerRadius / Math.cos(theta / 2));
			graphics.curveTo(cx, cy, bx, by);
		}
		
		graphics.endFill();
	}
	 
	 
	/**
	 * Draws a wedge shape onto a graphics instance.
	 * 
	 * @param 	graphics		a graphics instance on which to draw
	 * @param 	x				x position of the center of this wedge
	 * @param	y				y position of the center of this wedge
	 * @param	startAngle		the angle of one straight line of this wedge
	 * @param	arc				the angle (in degrees) of the total arc of this wedge
	 * @param	xRadius			the external radius along the x axis
	 * @param	yRadius			the external radius along the y axis
	 * @param	innerXRadius	the internal radius along the x axis
	 * @param	innerYRadius	the internal radius along the y axis
	 * @param	color			the color of the wedge fill
	 * @param	fillAlpha		the alpha value of the wedge fill
	 * 
	 * @return					nothing
	 */
	static public function drawWedge(
		graphics:Graphics, 
		x:Float, 
		y:Float, 
		startAngle:Float, 
		arc:Float, 
		xRadius:Float, 
		yRadius:Float, 
		innerXRadius:Float, 
		innerYRadius:Float, 
		color:Int = 0xFF0000, 
		fillAlpha:Float = 1 
	): Void
	{
		var segAngle:Float;
		var theta:Float;
		var angle:Float;
		var angleMid:Float;
		var segs:Int;
		var bx:Float;
		var by:Float;
		var cx:Float;
		var cy:Float;

		segs = Math.ceil(Math.abs(arc) / 45);
		segAngle = arc / segs;
		theta = -(segAngle / 180) * Math.PI;
		angle = -(startAngle / 180) * Math.PI;

		//graphics.lineStyle(0, 0x000000, 1);
		graphics.beginFill(color, fillAlpha);
		graphics.moveTo(
			x + Math.cos(startAngle / 180 * Math.PI) * innerXRadius,
			y + Math.sin(-startAngle / 180 * Math.PI) * innerYRadius 
		);

		// line 1
		graphics.lineTo(
			x + Math.cos(startAngle / 180 * Math.PI) * xRadius,
			y + Math.sin(-startAngle / 180 * Math.PI) * yRadius 
		);

		// outer arc
		for (i in 0 ... segs) {
			angle += theta;
			angleMid = angle - (theta / 2);
			bx = x + Math.cos(angle) * xRadius;
			by = y + Math.sin(angle) * yRadius;
			cx = x + Math.cos(angleMid) * (xRadius / Math.cos(theta / 2));
			cy = y + Math.sin(angleMid) * (yRadius / Math.cos(theta / 2));
			graphics.curveTo(cx, cy, bx, by);
		}

		// line 2
		graphics.lineTo(
			x + Math.cos((startAngle + arc) / 180 * Math.PI) * innerXRadius, 
			y + Math.sin(-(startAngle + arc) / 180 * Math.PI) * innerYRadius 
		);

		theta = -(segAngle / 180) * Math.PI;
		angle = -((startAngle + arc) / 180) * Math.PI;

		// inner arc
		for (j in 0 ... segs) {
			angle -= theta;
			angleMid = angle + (theta / 2);
			bx = x + Math.cos(angle) * innerXRadius;
			by = y + Math.sin(angle) * innerYRadius;
			cx = x + Math.cos(angleMid) * (innerXRadius / Math.cos(theta / 2));
			cy = y + Math.sin(angleMid) * (innerYRadius / Math.cos(theta / 2));
			graphics.curveTo(cx, cy, bx, by);
		}			
		graphics.endFill();			
	}
	
}