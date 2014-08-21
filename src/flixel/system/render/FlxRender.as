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
	 * TODO: add docs
	 * @author Dovyski
	 */
	public interface FlxRender 
	{
		/**
		 * TODO: add docs
		 * 
		 * @param	Game
		 * @param	StartGameCallback
		 */
		function init(Game:FlxGame, UpdateCallback:Function):void;
		
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