package flixel.system.render.genome2d 
{
	import com.genome2d.context.GContextConfig;
	import com.genome2d.context.IContext;
	import com.genome2d.Genome2D;
	import com.genome2d.textures.factories.GTextureFactory;
	import com.genome2d.textures.GTexture;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flixel.FlxCamera;
	import flixel.FlxG;
	import flixel.FlxGame;
	import flixel.FlxState;
	import flixel.system.render.FlxRender;
	
	/**
	 * TODO: add docs
	 * 
	 * Tutorial from: http://blog.flash-core.com/?p=3132
	 * 
	 * @author Dovyski
	 */
	public class FlxGenome2DRender implements FlxRender
	{
		[Embed(source="../../../../../../../FlixelSandbox/assets/bunny.png")] private var TexturePNG:Class;
		
		private var texture:GTexture;
		private var genome:Genome2D;
		private var updateCallback:Function;
		
		public function init(Game:FlxGame, UpdateCallback:Function):void
		{
			
			var config:GContextConfig = new GContextConfig(Game.stage, new Rectangle(0,0,Game.stage.stageWidth,Game.stage.stageHeight));
			 
			// Initialize Genome2D
			genome = Genome2D.getInstance();
			genome.onInitialized.addOnce(genomeInitializedHandler);
			genome.init(config);
			
			updateCallback = UpdateCallback;
		}
		
		private function genomeInitializedHandler():void
		{
			// We will create a single texture from an embedded bitmap
			//texture = GTextureFactory.createFromEmbedded("texture", TexturePNG);
			
			// Add a callback into the rendering pipeline
			// TODO: add docs explaining how it works. 
			genome.onPreRender.add(updateCallback);
		}
		
		public function draw(State:FlxState):void
		{
			//var context:IContext = genome.getContext();
			//context.draw(texture, 50, 50);
			//FlxG.log("working?" + FlxG.random.float());
			State.draw();
		}
		
		/**
		 * TODO: Render: add docs.
		 * TODO: find a better name for this method.
		 * 
		 * @param	Camera
		 * @param	sourceBitmapData
		 * @param	sourceRect
		 * @param	destPoint
		 * @param	alphaBitmapData
		 * @param	alphaPoint
		 * @param	mergeAlpha
		 */
		public function copyPixelsToBuffer(Camera:FlxCamera, sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Boolean = false):void
		{
			var context:IContext = genome.getContext();
			
			if(texture == null) {
				texture = GTextureFactory.createFromBitmapData("texture2", sourceBitmapData);
			}
			context.draw(texture, destPoint.x * Camera.zoom, destPoint.y * Camera.zoom, Camera.zoom, Camera.zoom);
			
			//context.drawSource(texture, sourceX, sourceY, sourceWidth, sourceHeight, x, y, scaleX, scaleY, rotation, red, green, blue, alpha, blendMode, filter);
			//FlxG.log("HOW?!");
		}
		
		/**
		 * TODO: Render: add docs.
		 * TODO: find a better name for this method.
		 * 
		 * @param	Camera
		 * @param	source
		 * @param	matrix
		 * @param	colorTransform
		 * @param	blendMode
		 * @param	clipRect
		 * @param	smoothing
		 */
		public function drawToBuffer(Camera:FlxCamera, source:IBitmapDrawable, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void
		{
			var context:IContext = genome.getContext();
			
			if(texture == null) {
				texture = GTextureFactory.createFromEmbedded("texture2", TexturePNG);
			}
			context.draw(texture, 10, 10);
			
			//context.drawSource(texture, sourceX, sourceY, sourceWidth, sourceHeight, x, y, scaleX, scaleY, rotation, red, green, blue, alpha, blendMode, filter);
			FlxG.log("here?");
		}
	}
}