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
	import flixel.system.render.FlxTexture;
	
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
		/**
		 * A reference to Genome2D backend.
		 */
		private var _genome:Genome2D;
		/**
		 * A callback function in the form <code>callback(e:FlashEvent=null)</code> that will be
		 * invoked by the render whenever it is ready to process the next frame.
		 */
		private var _updateCallback:Function;
		/**
		 * A texture that will be used to render Flixel camera FX e.g. flash and fade.
		 */
		private var _textureFX:GTexture;
		/**
		 * A reference to the configuration parameters used to init Genome2D.
		 */
		private var _config:GContextConfig;
		/**
		 * The debug buffer. Anything rendered using the <code>drawDebug()</code> method will be drawn to
		 * this buffer using blitting. It's is required to render debug information that change every frame,
		 * e.g. lines and bounding boxes. If this buffer doesn't exist, the render must upload the debug
		 * drawing to the GPU every frame, which would drastically hurt performance.
		 */
		private var _debugBuffer:BitmapData;
		/**
		 * The bitmap that will be added to the screen (Flash display list) to display the debug buffer
		 */
		private var _debugBufferContainer:Bitmap;
		/**
		 * A temporary matrix to save memory during the render process.
		 */
		private var _matrix:Matrix;
		/**
		 * A temporary rectangle to save memory during the render process.
		 */
		private var _rect:Rectangle;
		
		/**
		 * Initializes the render.
		 * 
		 * @param	Game				A reference to the game object.
		 * @param	StartGameCallback	A callback function in the form <code>callback(e:FlashEvent=null)</code> that will be invoked by the render whenever it is ready to process the next frame.
		 */
		public function init(Game:FlxGame, UpdateCallback:Function):void
		{
			
			_config = new GContextConfig(Game.stage, new Rectangle(0,0,Game.stage.stageWidth,Game.stage.stageHeight));
			 
			// Initialize Genome2D
			_genome = Genome2D.getInstance();
			_genome.onInitialized.addOnce(genomeInitializedHandler);
			_genome.init(_config);
			
			_updateCallback = UpdateCallback;
			
			// Initialize the debug buffer, used to draw things using blitting when GPU textures
			// are not available (e.g. dynamic debug lines).
			
			_debugBuffer = new BitmapData(Game.stage.stageWidth, Game.stage.stageHeight, true, 0x00000000);
			_debugBufferContainer = new Bitmap(_debugBuffer);
			
			Game.parent.addChild(_debugBufferContainer);
			_debugBufferContainer.visible = false;
			
			// TODO: improve this!
			_matrix = new Matrix();
			_rect = new Rectangle();
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
			// Blank screen to be used to draw camera effects (flash, fade, etc)
			var blankBitmap:BitmapData = new BitmapData(_config.viewRect.width, _config.viewRect.width, true, 0xFFFFFFFF);
			_textureFX = GTextureFactory.createFromBitmapData("_textureFX" + Math.random(), blankBitmap);
			
			// Add a callback into the rendering pipeline
			_genome.onPreRender.add(_updateCallback);
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
			var context:IContext = _genome.getContext();
			var totalCameras:uint = FlxG.cameras.length;
			var totalStateMembers:uint;
			var camera:FlxCamera;
			var basic:FlxBasic;
			var i:uint = 0;
			var j:uint = 0;
			var renderPosX :Number;
			var renderPosY :Number;
			
			if (_debugBufferContainer.visible)
			{
				// Debug buffer is active (visible), clear it before drawing anything.
				_debugBuffer.fillRect(_config.viewRect, 0x00000000);
				
				// Disable the debug buffer for this frame. If someone calls drawDebug()
				// during the rendering step, the debugBuffer will become visible again.
				_debugBufferContainer.visible = false;
			}
			
			while(i < totalCameras)
			{
				camera = FlxG.cameras[i++];
				
				if(camera == null || !camera.exists || !camera.visible)
					continue;
					
				// Define the camera clip rectangle. It will ensure the render draws
				// only what the camera should display, nothing outside this area.
				_rect.x = camera.x * camera.zoom;
				_rect.y = camera.y * camera.zoom;
				_rect.width = camera.width * camera.zoom;
				_rect.height = camera.height * camera.zoom;
				context.setMaskRect(_rect);
				
				// Calculate the rendering position based on camera position and effects (shake, etc)
				renderPosX = (camera.fxShakeOffset.x + camera.x + camera.width / 2) * camera.zoom;
				renderPosY = (camera.fxShakeOffset.y + camera.y + camera.height / 2) * camera.zoom;
				
				// Render the camera background. It's the equivalent of calling camera.fill() in the blitting render.
				context.setBackgroundColor(camera.bgColor);
				context.draw(camera.bgTexture.gpuData, renderPosX, renderPosY, camera.zoom, camera.zoom, 0, camera.colorTransform.redMultiplier, camera.colorTransform.greenMultiplier, camera.colorTransform.blueMultiplier);
				
				// Iterate over every entry in the state, rendering it.
				j = 0;
				totalStateMembers = State.members.length;
				while (j < totalStateMembers)
				{
					basic = State.members[j++];
					
					if (basic != null && basic.exists && basic.visible)
					{
						basic.draw(camera);
					}
				}
				
				// Render the camera FXs.
				camera.drawFX();
				
				if (camera.hasActiveColorFX())
				{
					// The rendering position for the textureFX should match the camera's X and Y position, since it 
					// doesn't move with camera effects (e.g. shaking).
					renderPosX = (camera.x + camera.width / 2) * camera.zoom;
					renderPosY = (camera.y + camera.height / 2) * camera.zoom;
					
					// TODO: make camera's fxColorAcumulator a FlxColor and read it using camera.fxColor.r, camera.fxColor.b, etc.
					context.draw(_textureFX, renderPosX, renderPosY, camera.zoom, camera.zoom, 0, ((camera.fxColorAcumulator >> 16) & 0xFF) / 255.0, ((camera.fxColorAcumulator >> 8) & 0xFF) / 255.0, (camera.fxColorAcumulator & 0xFF) / 255.0, ((camera.fxColorAcumulator >> 24) & 0xFF) / 255.0, GBlendMode.NORMAL);
				}
				
				// Reset the camera fxColor accumulation buffer.
				camera.fxColorAcumulator = 0;
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
			var context:IContext = _genome.getContext();
			
			context.drawSource(	SourceTexture.gpuData,
								SourceRect.x,
								SourceRect.y,
								SourceRect.width,
								SourceRect.height,
								(Camera.fxShakeOffset.x + Camera.x + DestPoint.x + SourceRect.width / 2) * Camera.zoom,
								(Camera.fxShakeOffset.y + Camera.y + DestPoint.y + SourceRect.height / 2) * Camera.zoom,
								Camera.zoom,
								Camera.zoom);
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
			var context:IContext = _genome.getContext();

			context.drawMatrixSource(SourceTexture.gpuData,
									 SourceRect.x,
									 SourceRect.y,
									 SourceRect.width,
									 SourceRect.height,
									 TransMatrix.a * Camera.zoom,
									 TransMatrix.b * Camera.zoom,
									 TransMatrix.c * Camera.zoom,
									 TransMatrix.d * Camera.zoom,
									 (TransMatrix.tx + Camera.fxShakeOffset.x) * Camera.zoom,
									 (TransMatrix.ty + Camera.fxShakeOffset.y) * Camera.zoom);
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
			_matrix.createBox(Camera.zoom, Camera.zoom, 0, 1, 1);

			_debugBufferContainer.visible = true;
			_debugBuffer.draw(Source, _matrix);
		}
	}
}