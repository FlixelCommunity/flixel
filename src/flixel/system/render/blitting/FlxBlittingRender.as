package flixel.system.render.blitting 
{
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flixel.*;
	import flixel.system.render.FlxRender;
	import flixel.system.render.FlxTexture;
	
	/**
	 * A CPU render based on blitting. It uses Bitmaps draw thing into the screen, copying pixels
	 * from one place to another. It is not based on hardware acceleration, so it tends to be slower as the
	 * number of sprites to be rendered increases.
	 * 
	 * @author Dovyski
	 */
	public class FlxBlittingRender implements FlxRender
	{
		/**
		 * Initializes the render.
		 * 
		 * @param	Game				A reference to the game object.
		 * @param	StartGameCallback	A callback function in the form <code>callback(e:FlashEvent=null)</code> that will be invoked by the render whenever it is ready to process the next frame.
		 */		
		public function init(Game:FlxGame, UpdateCallback:Function):void 
		{
			Game.stage.addEventListener(Event.ENTER_FRAME, UpdateCallback);
		}
		
		/**
		 * Returns a few information about the render. That info displayed at the bottom of the performance
		 * overlay when debug information is active.
		 * 
		 * @return A string containing information about the render, e.g. "Blitting" or "GPU (Genome2D)".
		 */
		public function get info():String
		{
			return "CPU Blitting";
		}
		
		/**
		 * Tells if the render is working with blitting (copying pixels using BitmapData) or not.
		 * 
		 * @return <code>true</code> true if blitting is being used to display things into the screen, or <code>false</code> otherwise (using GPU).
		 */
		public function isBlitting():Boolean
		{
			return true;
		}
		
		/**
		 * Performs a graphic step, rendering all elements into the screen. Flixel will invoke this method after
		 * it has updated all game entities. This method *should not* be invoked directly since Flixel will do
		 * it automatically at the right time.
		 * 
		 * @param	State	The state whose elements will be rendered into the screen.
		 */
		public function step(State:FlxState):void
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
		 * Draw the source object into the screen with no stretching, rotation, or color effects. 
		 * This method renders a rectangular area of a source image to a rectangular area of the same size
		 * at the destination point of the informed destination.
		 * 
		 * @param	Camera				The camera that is being rendered to the screen at the moment.
		 * @param	SourceTexture		A GPU texture representing the graphic to be rendered.
		 * @param	SourceBitmapData	A bitmapData representing the graphic to be rendered.
		 * @param	SourceRect			A rectangle that defines the area of the source image to use as input.
		 * @param	DestPoint			The destination point that represents the upper-left corner of the rectangular area where the new pixels are placed.
		 * @param	AlphaBitmapData		A secondary, alpha BitmapData object source.
		 * @param	AlphaPoint			The point in the alpha BitmapData object source that corresponds to the upper-left corner of the SourceRect parameter.
		 * @param	MergeAlpha			To use the alpha channel, set the value to true. To copy pixels with no alpha channel, set the value to <code>false</code>
		 */
		public function copyPixels(Camera:FlxCamera, SourceTexture:FlxTexture, SourceBitmapData:BitmapData, SourceRect:Rectangle, DestPoint:Point, AlphaBitmapData:BitmapData = null, AlphaPoint:Point = null, MergeAlpha:Boolean = false):void
		{
			Camera.buffer.copyPixels(SourceBitmapData, SourceRect, DestPoint, AlphaBitmapData, AlphaPoint, MergeAlpha);
		}
		
		/**
		 * Draws the source display object into the screen using transformations. You can specify matrix, colorTransform, 
		 * blendMode, and a destination ClipRect parameter to control how the rendering performs.
		 * Optionally, you can specify whether the bitmap should be smoothed when scaled (this works only if the source object
		 * is a BitmapData object).
		 * 
		 * This method is an imitation of <code>BitmapData#draw()</code>.
		 * 
		 * @param	Camera				The camera that is being rendered to the screen at the moment.
		 * @param	SourceTexture		A GPU texture representing the graphic to be rendered.
		 * @param	Source				A bitmapData representing the graphic to be rendered.
		 * @param	SourceRect			A rectangle that defines the area of the source image to use as input.
		 * @param	TransMatrix			A Matrix object used to scale, rotate, or translate the coordinates of the input. It's <code>null</code> by default, meaning no transformation will be applied.
		 * @param	ColorTrans			A ColorTransform object used to adjust the color values of the input during rendering. It's <code>null</code> by default, meaning no transformation will be applied.
		 * @param	BlendMode			A string value, from the <code>flash.display.BlendMode</code> class, specifying the blend mode to be applied during rendering.
		 * @param	ClipRect			A Rectangle object that defines the area of the source object to draw. If <code>null</code> is provided (default), no clipping occurs and the entire source object is drawn.
		 * @param	Smoothing			A Boolean value that determines whether a the source object is smoothed when scaled or rotated, due to a scaling or rotation in the Matrix parameter.
		 */
		public function draw(Camera:FlxCamera, SourceTexture:FlxTexture, Source:IBitmapDrawable, SourceRect:Rectangle, TransMatrix:Matrix = null, ColorTrans:ColorTransform = null, BlendMode:String = null, ClipRect:Rectangle = null, Smoothing:Boolean = false):void
		{
			Camera.buffer.draw(Source, TransMatrix, ColorTrans, BlendMode, ClipRect, Smoothing);
		}
		
		/**
		 * Draws generic graphics to the screen using a blitting debug buffer. Highly changing graphics, such as debug lines, cannot be uploaed to
		 * the GPU every frame, so the render provides this method that renders a source object to a special buffer using blitting.
		 * This method should be used when performance is not a concern, e.g. when debug overlays are being rendered.
		 * 
		 * @param	Camera				The camera that is being rendered to the screen at the moment.
		 * @param	source				The display object or BitmapData object to draw to the BitmapData object.
		 */
		public function drawDebug(Camera:FlxCamera, Source:IBitmapDrawable):void
		{
			Camera.buffer.draw(Source);
		}
	}
}