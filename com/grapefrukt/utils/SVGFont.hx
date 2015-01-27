package com.grapefrukt.utils;
import format.svg.FillType;
import format.svg.Path;
import format.svg.PathParser;
import format.svg.PathSegment;
import format.svg.RenderContext;
import format.svg.SVGData;
import format.svg.SVGRenderer;
import openfl.Assets;
import openfl.display.CapsStyle;
import openfl.display.Graphics;
import openfl.display.JointStyle;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Martin Jonasson, m@grapefrukt.com
 */

using StringTools;
 
class SVGFont {
	
	var glyphs:Map<Int, SVGGlyph>;
	var renderer:HaxSVGRenderer;
	
	public var unitsPerEM(default, null):Float;
	public var boundingBox(default, null):Rectangle;
	public var pad:Rectangle;

	public function new(path:String) {
		glyphs = new Map();
		renderer = new HaxSVGRenderer(null);
		
		pad = new Rectangle(66, 284);
		
		var textData = Assets.getText(path);
		var xml = Xml.parse(textData);
		var parser = new PathParser();
		
		for (svg in xml.elements()) {
			if (svg.nodeName != 'svg') continue;
			
			for (defs in svg.elements()) {
				if (defs.nodeName != 'defs') continue;
				
				for (font in defs.elements()){
					if (font.nodeName != 'font') continue;
					
					for (fontFace in font.elements()) {
						if (fontFace.nodeName != 'font-face') continue;
						
						unitsPerEM = Std.parseFloat(fontFace.get('units-per-em'));
						
						var bbox = fontFace.get('bbox').split(' ');
						boundingBox = new Rectangle();
						boundingBox.left 	= Std.parseFloat(bbox[0]);
						boundingBox.bottom 	= Std.parseFloat(bbox[1]);
						boundingBox.right 	= Std.parseFloat(bbox[2]);
						boundingBox.top 	= Std.parseFloat(bbox[3]);
					}
					
					for (glyph in font.elements()) {
						if (glyph.nodeName != 'glyph') continue;
						var key = glyph.get('unicode');
						if (key == null) continue;
						
						var horzAdv = Std.parseFloat(glyph.get('horiz-adv-x'));
						// glyph has no own width data, use the font default
						if (Math.isNaN(horzAdv)) horzAdv = Std.parseFloat(font.get('horiz-adv-x'));
						
						var path:Path = null;
						
						// get glyph data, not all glyphs will have data (whitespace)
						var d:String = glyph.get('d');
						if (d != null && d != "") {
							var segments = parser.parse(d, true);
							path = makePath(segments);
						}
						
						var glyph = new SVGGlyph(horzAdv, path);
						glyphs.set(key.fastCodeAt(0), glyph);
					}
				}
			}
		}
	}
	
	public function renderString(string:String, graphics:Graphics, fontSize:Float = 16, color:Int = 0x000000, maxWidth:Float = -1) {
		renderer.reset(this, graphics, fontSize, color);
		var linebreakAfter = [];
		
		if (maxWidth >= 0) {
			var x = .0;
			var i = -1;
			var lastPossibleBreak = -1;
			// go forward in the string until we exceed the maxWidth or find an explicit linebreak
			while (i++ < string.length) {
				x += getWidth(string.fastCodeAt(i));
				var doBreak = x > maxWidth;
				
				if (isBreakable(string.fastCodeAt(i))) lastPossibleBreak = i;
				if (isLinebreak(string.fastCodeAt(i))) {
					lastPossibleBreak = i;
					doBreak = true;
				}
				
				// when that happens, start going back again to the first breakable char
				if (doBreak && lastPossibleBreak >= 0) {
					//trace('exceeded width at char #$i (${string.charAt(i)})');
					linebreakAfter.push(lastPossibleBreak);
					lastPossibleBreak = -1;
					x = 0;
				}
			}
		}
		
		var lineIndex = 0;
		for (i in 0 ... string.length) {
			renderer.renderGlyph(glyphs.get(string.fastCodeAt(i)));
			
			if (linebreakAfter.length > 0 && linebreakAfter[lineIndex] == i) {
				lineIndex++;
				renderer.linefeed(lineIndex);
			} 
		}
	}
	
	function getWidth(charCode:Int) {
		return glyphs.exists(charCode) ? renderer.unitsToPx(glyphs.get(charCode).horzAdv) : 0;
	}
	
	function isBreakable(charCode:Int) {
		if (charCode == ' '.fastCodeAt(0)) return true;
		return false;
	}
	
	function makePath(segments:Array<PathSegment>) {
		var p = new Path();
		p.matrix = new Matrix();
		p.segments = segments;
		
		return p;
	}
}

private class HaxSVGRenderer extends SVGRenderer {
	
	var fontSize:Float;
	var font:SVGFont;
	var color:Int;
	
	public function new(graphics:Graphics) {
		var placeholder = Xml.createElement('xml');
		placeholder.addChild(Xml.createElement('svg'));
		mMatrix = new Matrix();
		super(new SVGData(placeholder));
	}
	
	public function reset(font:SVGFont, graphics:Graphics, fontSize:Float, color:Int) {
		this.color = color;
		this.font = font;
		this.fontSize = fontSize;
		
		mGfx = new format.gfx.GfxGraphics(graphics);
		linefeed();
	}
	
	public function linefeed(lineIndex:Int = 0) {
		mMatrix.identity();
		var scale = (1 / font.unitsPerEM) * fontSize;
		mMatrix.scale(scale, -scale);
		mMatrix.translate(unitsToPx(font.boundingBox.left), unitsToPx(font.boundingBox.top));
		mMatrix.translate(unitsToPx(font.pad.left), unitsToPx(font.pad.top));
		mMatrix.translate(0, -unitsToPx(font.boundingBox.height) * lineIndex);
	}
	
	public function renderGlyph(glyph:SVGGlyph) {
		// check that glyph exists (linebreaks will trigger this)
		if (glyph == null) return;
		// check that the glyph has a path (spaces do not)
		if (glyph.path != null) iteratePath(glyph.path);
		// move the "caret"
		mMatrix.translate(unitsToPx(glyph.horzAdv), 0);
	}
	
	public function unitsToPx(units:Float) {
		return (units / font.unitsPerEM) * fontSize;
	}
	
	override public function iteratePath(inPath:Path) {
		if (mFilter != null && !mFilter(inPath.name, mGroupPath)) return;
		if (inPath.segments.length == 0 || mGfx == null) return;
		
		var px = 0.0;
		var py = 0.0;
		
		var context = new RenderContext(mMatrix, mScaleRect, mScaleW, mScaleH);

		mGfx.beginFill(color, 1);
		
		for(segment in inPath.segments)
			segment.toGfx(mGfx, context);

		mGfx.endFill();
		mGfx.endLineStyle();
	}
}


class SVGGlyph {
	
	public var path(default, null):Path;
	public var horzAdv(default, null):Float;
	
	public function new(horzAdv:Float, path:Path) {
		this.horzAdv = horzAdv;
		this.path = path;
	}
}