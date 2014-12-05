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
class SVGFont {
	
	var glyphs:Map<String, SVGGlyph>;
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
						glyphs.set(key, glyph);
					}
				}
			}
		}
	}
	
	public function renderString(string:String, graphics:Graphics, fontSize:Float = 16, color:Int = 0x000000) {
		renderer.reset(this, graphics, fontSize, color);
		for (char in string.split('')) renderer.renderGlyph(glyphs.get(char));
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
		super(new SVGData(placeholder));
	}
	
	public function reset(font:SVGFont, graphics:Graphics, fontSize:Float, color:Int) {
		this.color = color;
		this.font = font;
		this.fontSize = fontSize;
		
		mGfx = new format.gfx.GfxGraphics(graphics);
		
		var scale = (1 / font.unitsPerEM) * fontSize;
		
		mMatrix = new Matrix();
		mMatrix.scale(scale, -scale);
		mMatrix.translate(unitsToPx(font.boundingBox.left), unitsToPx(font.boundingBox.top));
		mMatrix.translate(unitsToPx(font.pad.left), unitsToPx(font.pad.top));
	}
	
	public function renderGlyph(glyph:SVGGlyph) {
		if (glyph.path != null) iteratePath(glyph.path);
		mMatrix.translate(unitsToPx(glyph.horzAdv), 0);
	}
	
	function unitsToPx(units:Float) {
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