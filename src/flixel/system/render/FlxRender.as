package flixel.system.render 
{
	import com.genome2d.textures.GTexture;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flixel.FlxCamera;
	import flixel.FlxGame;
	import flixel.FlxState;
	
	/**
	 * Interface that defines how all renders must be structured. When Flixel has updated the current game frame, it will
	 * invoke the render's drawing method to display everything on the screen.
	 * 
	 * @author Dovyski
	 */
	public interface FlxRender 
	{
		/**
		 * Initializes the render.
		 * 
		 * @param	Game				A reference to the game object.
		 * @param	StartGameCallback	A callback function in the form <code>callback(e:FlashEvent=null)</code> that will be invoked by the render whenever it is ready to process the next frame.
		 */
		function init(Game:FlxGame, UpdateCallback:Function):void;
		
		/**
		 * Returns a few information about the render. That info displayed at the bottom of the performance
		 * overlay when debug information is active.
		 * 
		 * @return A string containing information about the render, e.g. "Blitting" or "GPU (Genome2D)".
		 */
		function get info():String;
		
		/**
		 * Tells if the render is working with blitting (copying pixels using BitmapData) or not.
		 * 
		 * @return <code>true</code> true if blitting is being used to display things into the screen, or <code>false</code> otherwise (using GPU).
		 */
		function isBlitting():Boolean;
		
		/**
		 * TODO: add docs
		 * 
		 * @param	State
		 */
		function draw(State:FlxState):void;
		
		/**
		 * TODO: Render: add docs.
		 * TODO: find a better name for this method.
		 * 
		 * @param	Camera
		 * @param	sourceTexture
		 * @param	sourceBitmapData
		 * @param	sourceRect
		 * @param	destPoint
		 * @param	alphaBitmapData
		 * @param	alphaPoint
		 * @param	mergeAlpha
		 */
		function copyPixelsToBuffer(Camera:FlxCamera, sourceTexture:GTexture ,sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Boolean = false):void;
		
		/**
		 * TODO: Render: add docs.
		 * TODO: find a better name for this method.
		 * 
		 * @param	Camera
		 * @param	sourceTexture
		 * @param	source
		 * @param	sourceRect
		 * @param	matrix
		 * @param	colorTransform
		 * @param	blendMode
		 * @param	clipRect
		 * @param	smoothing
		 */
		function drawToBuffer(Camera:FlxCamera, sourceTexture:GTexture, source:IBitmapDrawable, sourceRect:Rectangle, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void;
	}
}