package flixel.system.render.genome2d 
{
	import com.genome2d.context.GBlendMode;
	import com.genome2d.context.GContextCamera;
	import com.genome2d.context.GContextConfig;
	import com.genome2d.context.IContext;
	import com.genome2d.Genome2D;
	import com.genome2d.textures.factories.GTextureFactory;
	import com.genome2d.textures.GTexture;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.IBitmapDrawable;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flixel.FlxBasic;
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
		private var genome:Genome2D;
		private var updateCallback:Function;
		private var textureFX:GTexture;
		private var config:GContextConfig;
		
		public function init(Game:FlxGame, UpdateCallback:Function):void
		{
			
			config = new GContextConfig(Game.stage, new Rectangle(0,0,Game.stage.stageWidth,Game.stage.stageHeight));
			 
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
			
			// Blank screen to be used to draw camera effects (flash, fade, etc)
			var blankBitmap:BitmapData = new BitmapData(config.viewRect.width, config.viewRect.width, true, 0xFFFFFFFF);
			textureFX = GTextureFactory.createFromBitmapData("textureFX" + Math.random(), blankBitmap);
			
			// Add a callback into the rendering pipeline
			// TODO: add docs explaining how it works. 
			genome.onPreRender.add(updateCallback);
		}
		
		public function draw(State:FlxState):void
		{
			var context:IContext = genome.getContext();
			var l:uint = FlxG.cameras.length;
			var camera:FlxCamera;
			var basic:FlxBasic;
			var i:uint = 0;
			
			while(i < l)
			{
				camera = FlxG.cameras[i++];
				
				if(camera == null || !camera.exists || !camera.visible)
					continue;
					
				context.setMaskRect(new Rectangle(camera.x * camera.zoom, camera.y * camera.zoom, camera.width * camera.zoom, camera.height * camera.zoom)); // TODO: Render: improve rectangle allocation
				context.draw(camera.texture, (camera.fxShakeOffset.x + camera.x + camera.width / 2) * camera.zoom, (camera.fxShakeOffset.y + camera.y + camera.height / 2) * camera.zoom, camera.zoom, camera.zoom, 0, camera.colorTransform.redMultiplier, camera.colorTransform.greenMultiplier, camera.colorTransform.blueMultiplier);
				
				var j:uint = 0;
				while (j < State.members.length)
				{
					basic = State.members[j++];
					
					if (basic != null && basic.exists && basic.visible)
					{
						basic.draw(camera);
					}
				}
				
				camera.drawFX();
				
				if (camera.hasActiveColorFX())
				{
					context.setMaskRect(new Rectangle(camera.x * camera.zoom, camera.y * camera.zoom, camera.width * camera.zoom, camera.height * camera.zoom)); // TODO: Render: improve rectangle allocation
					// TODO: make camera's fxColorAcumulator a FlxColor and read it using camera.fxColor.r, camera.fxColor.b, etc.
					context.draw(textureFX, (camera.x + camera.width / 2) * camera.zoom, (camera.y + camera.height / 2) * camera.zoom, camera.zoom, camera.zoom, 0, ((camera.fxColorAcumulator >> 16) & 0xFF) / 255.0, ((camera.fxColorAcumulator >> 8) & 0xFF) / 255.0, (camera.fxColorAcumulator & 0xFF) / 255.0, ((camera.fxColorAcumulator >> 24) & 0xFF) / 255.0, GBlendMode.NORMAL);
				}
				
				camera.fxColorAcumulator = 0;
			}
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
		public function copyPixelsToBuffer(Camera:FlxCamera, sourceTexture:GTexture, sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Boolean = false):void
		{
			var context:IContext = genome.getContext();
			
			context.setBackgroundColor(Camera.bgColor);
			context.setMaskRect(new Rectangle(Camera.x * Camera.zoom, Camera.y * Camera.zoom, Camera.width * Camera.zoom, Camera.height * Camera.zoom)); // TODO: improve rectangle allocation
			context.drawSource(sourceTexture, sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, (Camera.fxShakeOffset.x + Camera.x + destPoint.x + sourceRect.width/2) * Camera.zoom, (Camera.fxShakeOffset.y + Camera.y + destPoint.y + sourceRect.height/2) * Camera.zoom, Camera.zoom, Camera.zoom);
		}
		
		/**
		 * TODO: Render: add docs.
		 * TODO: find a better name for this method.
		 * 
		 * @param	Camera
		 * @param	source
		 * @param	sourceRect
		 * @param	matrix
		 * @param	colorTransform
		 * @param	blendMode
		 * @param	clipRect
		 * @param	smoothing
		 */
		public function drawToBuffer(Camera:FlxCamera, sourceTexture:GTexture, source:IBitmapDrawable, sourceRect:Rectangle, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void
		{
			var context:IContext = genome.getContext();

			context.setBackgroundColor(Camera.bgColor);
			context.setMaskRect(new Rectangle(Camera.x * Camera.zoom, Camera.y * Camera.zoom, Camera.width * Camera.zoom, Camera.height * Camera.zoom));
			context.drawMatrixSource(sourceTexture, sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, matrix.a * Camera.zoom, matrix.b * Camera.zoom, matrix.c * Camera.zoom, matrix.d * Camera.zoom, (matrix.tx + Camera.fxShakeOffset.x) * Camera.zoom, (matrix.ty + Camera.fxShakeOffset.y)* Camera.zoom);
		}
	}
}