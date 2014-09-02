package flixel.system.render.blitting 
{
	import com.genome2d.textures.GTexture;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flixel.*;
	import flixel.system.render.FlxRender;
	
	/**
	 * TODO: add docs
	 * @author Dovyski
	 */
	public class FlxBlittingRender implements FlxRender
	{
		public function init(Game:FlxGame, UpdateCallback:Function):void 
		{
			Game.stage.addEventListener(Event.ENTER_FRAME, UpdateCallback);
		}
		
		public function draw(State:FlxState):void
		{
			var cam:FlxCamera;
			var cams:Array = FlxG.cameras;
			var i:uint = 0;
			var l:uint = cams.length;
			while(i < l)
			{
				cam = cams[i++] as FlxCamera;
				if((cam == null) || !cam.exists || !cam.visible)
					continue;
				
				if(FlxG.useBufferLocking)
					cam.buffer.lock();
				
				cam.fill(cam.bgColor);
				cam.screen.dirty = true;
				State.draw(cam);
				cam.drawFX();
				
				if(FlxG.useBufferLocking)
					cam.buffer.unlock();
			}
		}
		
		/**
		 * TODO: Render: add docs.
		 * 
		 * @param	Camera
		 * @param	sourceBitmapData
		 * @param	sourceRect
		 * @param	destPoint
		 * @param	alphaBitmapData
		 * @param	alphaPoint
		 * @param	mergeAlpha
		 */
		public function copyPixelsToBuffer(Camera:FlxCamera, sourceTexture:GTexture,sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Boolean = false):void
		{
			Camera.buffer.copyPixels(sourceBitmapData, sourceRect, destPoint, alphaBitmapData, alphaPoint, mergeAlpha);
		}
		
		/**
		 * TODO: Render: add docs.
		 * 
		 * @param	Camera
		 * @param	source
		 * @param	matrix
		 * @param	colorTransform
		 * @param	blendMode
		 * @param	clipRect
		 * @param	smoothing
		 */
		public function drawToBuffer(Camera:FlxCamera, sourceTexture:GTexture, source:IBitmapDrawable, sourceRect:Rectangle, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void
		{
			Camera.buffer.draw(source, matrix, colorTransform, blendMode, clipRect, smoothing);
		}
	}
}