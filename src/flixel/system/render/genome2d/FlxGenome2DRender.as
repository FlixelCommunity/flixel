package flixel.system.render.genome2d 
{
	import com.genome2d.context.GBlendMode;
	import com.genome2d.context.GContextCamera;
	import com.genome2d.context.GContextConfig;
	import com.genome2d.context.IContext;
	import com.genome2d.Genome2D;
	import com.genome2d.textures.factories.GTextureFactory;
	import com.genome2d.textures.GTexture;
	import flash.display.Bitmap;
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
	 * A GPU render based on Genome2D (http://genome2d.com). It uses hardware acceleration (GPU) to draw elements into the
	 * screen, which makes it a lot faster than the blitting render. Since it is lighter on the CPU processing, it should be battery friendly
	 * and a better fit for mobile development.
	 * 
	 * This render uses Genome2D low-level API to draw everything. Genome2D's rendering pipeline is significantly different compared to a blitting 
	 * pipeline, so a few adaptations were made to ensure performance. 
	 * 
	 * This render was implemented following this tutorial: http://blog.flash-core.com/?p=3132
	 * 
	 * @author Dovyski
	 */
	public class FlxGenome2DRender implements FlxRender
	{
		private var genome:Genome2D;
		private var updateCallback:Function;
		private var textureFX:GTexture;
		private var config:GContextConfig;
		private var debugBuffer:BitmapData;
		private var debugBufferContainer:Bitmap;
		private var m:Matrix;
		
		/**
		 * Initializes the render.
		 * 
		 * @param	Game				A reference to the game object.
		 * @param	StartGameCallback	A callback function in the form <code>callback(e:FlashEvent=null)</code> that will be invoked by the render whenever it is ready to process the next frame.
		 */
		public function init(Game:FlxGame, UpdateCallback:Function):void
		{
			
			config = new GContextConfig(Game.stage, new Rectangle(0,0,Game.stage.stageWidth,Game.stage.stageHeight));
			 
			// Initialize Genome2D
			genome = Genome2D.getInstance();
			genome.onInitialized.addOnce(genomeInitializedHandler);
			genome.init(config);
			
			updateCallback = UpdateCallback;
			
			// Initialize the debug buffer, used to draw things using blitting when GPU textures
			// are not available (e.g. dynamic debug lines).
			
			debugBuffer = new BitmapData(Game.stage.stageWidth, Game.stage.stageHeight, true, 0xFF000000);
			debugBufferContainer = new Bitmap(debugBuffer);
			
			Game.parent.addChild(debugBufferContainer);
			debugBufferContainer.visible = false;
			
			// TODO: improve this!
			m = new Matrix();
		}
		
		/**
		 * Returns a few information about the render. That info displayed at the bottom of the performance
		 * overlay when debug information is active.
		 * 
		 * @return A string containing information about the render, e.g. "Blitting" or "GPU (Genome2D)".
		 */
		public function get info():String
		{
			return "GPU Genome2D " + Genome2D.VERSION;
		}
		
		/**
		 * Tells if the render is working with blitting (copying pixels using BitmapData) or not.
		 * 
		 * @return <code>true</code> true if blitting is being used to display things into the screen, or <code>false</code> otherwise (using GPU).
		 */
		public function isBlitting():Boolean
		{
			return false;
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
		
		/**
		 * Performs a graphic step, rendering all elements into the screen. Flixel will invoke this method after
		 * it has updated all game entities. This method *should not* be invoked directly since Flixel will do
		 * it automatically at the right time.
		 * 
		 * @param	State	The state whose elements will be rendered into the screen.
		 */
		public function step(State:FlxState):void
		{
			var context:IContext = genome.getContext();
			var l:uint = FlxG.cameras.length;
			var camera:FlxCamera;
			var basic:FlxBasic;
			var i:uint = 0;
			
			// TODO: improve this! it's being called for every draw call, but it is required only when the debug buffer is in use.
			debugBuffer.fillRect(config.viewRect, 0x00000000);
			
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
		 * Draw the source object into the screen with no stretching, rotation, or color effects. 
		 * This method renders a rectangular area of a source image to a rectangular area of the same size
		 * at the destination point of the informed destination.
		 * 
		 * @param	Camera				The camera that is being rendered to the screen at the moment.
		 * @param	sourceTexture		TODO: encapsulate it under FlxTexture.
		 * @param	sourceBitmapData	TODO: encapsulate it under FlxTexture.
		 * @param	sourceRect			A rectangle that defines the area of the source image to use as input.
		 * @param	destPoint			The destination point that represents the upper-left corner of the rectangular area where the new pixels are placed.
		 * @param	alphaBitmapData		A secondary, alpha BitmapData object source.
		 * @param	alphaPoint			The point in the alpha BitmapData object source that corresponds to the upper-left corner of the sourceRect parameter.
		 * @param	mergeAlpha			To use the alpha channel, set the value to true. To copy pixels with no alpha channel, set the value to <code>false</code>
		 */
		public function copyPixels(Camera:FlxCamera, sourceTexture:GTexture, sourceBitmapData:BitmapData, sourceRect:Rectangle, destPoint:Point, alphaBitmapData:BitmapData = null, alphaPoint:Point = null, mergeAlpha:Boolean = false):void
		{
			var context:IContext = genome.getContext();
			
			context.setBackgroundColor(Camera.bgColor);
			context.setMaskRect(new Rectangle(Camera.x * Camera.zoom, Camera.y * Camera.zoom, Camera.width * Camera.zoom, Camera.height * Camera.zoom)); // TODO: improve rectangle allocation
			context.drawSource(sourceTexture, sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, (Camera.fxShakeOffset.x + Camera.x + destPoint.x + sourceRect.width / 2) * Camera.zoom, (Camera.fxShakeOffset.y + Camera.y + destPoint.y + sourceRect.height / 2) * Camera.zoom, Camera.zoom, Camera.zoom);
		}
		
		/**
		 * Draws the source display object into the screen using transformations. You can specify matrix, colorTransform, 
		 * blendMode, and a destination clipRect parameter to control how the rendering performs.
		 * Optionally, you can specify whether the bitmap should be smoothed when scaled (this works only if the source object
		 * is a BitmapData object).
		 * 
		 * This method is an imitation of <code>BitmapData#draw()</code>.
		 * 
		 * @param	Camera				The camera that is being rendered to the screen at the moment.
		 * @param	sourceTexture		TODO: encapsulate it under FlxTexture.
		 * @param	source				TODO: encapsulate it under FlxTexture.
		 * @param	sourceRect			A rectangle that defines the area of the source image to use as input.
		 * @param	matrix				A Matrix object used to scale, rotate, or translate the coordinates of the input. It's <code>null</code> by default, meaning no transformation will be applied.
		 * @param	colorTransform		A ColorTransform object used to adjust the color values of the input during rendering. It's <code>null</code> by default, meaning no transformation will be applied.
		 * @param	blendMode			A string value, from the <code>flash.display.BlendMode</code> class, specifying the blend mode to be applied during rendering.
		 * @param	clipRect			A Rectangle object that defines the area of the source object to draw. If <code>null</code> is provided (default), no clipping occurs and the entire source object is drawn.
		 * @param	smoothing			A Boolean value that determines whether a the source object is smoothed when scaled or rotated, due to a scaling or rotation in the matrix parameter.
		 */
		public function draw(Camera:FlxCamera, sourceTexture:GTexture, source:IBitmapDrawable, sourceRect:Rectangle, matrix:Matrix = null, colorTransform:ColorTransform = null, blendMode:String = null, clipRect:Rectangle = null, smoothing:Boolean = false):void
		{
			var context:IContext;
			
			context = genome.getContext();

			context.setBackgroundColor(Camera.bgColor);
			context.setMaskRect(new Rectangle(Camera.x * Camera.zoom, Camera.y * Camera.zoom, Camera.width * Camera.zoom, Camera.height * Camera.zoom));
			context.drawMatrixSource(sourceTexture, sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height, matrix.a * Camera.zoom, matrix.b * Camera.zoom, matrix.c * Camera.zoom, matrix.d * Camera.zoom, (matrix.tx + Camera.fxShakeOffset.x) * Camera.zoom, (matrix.ty + Camera.fxShakeOffset.y) * Camera.zoom);
		}
		
		/**
		 * Draws generic graphics to the screen using a blitting debug buffer. Highly changing graphics, such as debug lines, cannot be uploaed to
		 * the GPU every frame, so the render provides this method that renders a source object to a special buffer using blitting.
		 * This method should be used when performance is not a concern, e.g. when debug overlays are being rendered.
		 * 
		 * @param	Camera				The camera that is being rendered to the screen at the moment.
		 * @param	source				The display object or BitmapData object to draw to the BitmapData object.
		 */
		public function drawDebug(Camera:FlxCamera, source:IBitmapDrawable):void
		{
			// TODO: improve this line
			m.createBox(Camera.zoom, Camera.zoom);

			debugBufferContainer.visible = true;
			debugBuffer.draw(source, m);
		}
	}
}