package flixel.system.render {
	import com.genome2d.textures.factories.GTextureFactory;
	import com.genome2d.textures.GTexture;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flixel.FlxG;
	
	/**
	 * A class to abstract the creation and manipulation of graphics (in BitmapData or GPU textures). The class will
	 * work based on the current render, uploading data to the GPU if Flixel is running in GPU mode.
	 * 
	 * @author Fernando Bevilacqua
	 */
	public class FlxTexture
	{
		/**
		 * The bitmapData of the texture.
		 */
		protected var _bitmapData:BitmapData;
		/**
		 * A reference to the GPU memory where the texture was uploaded to.
		 */
		protected var _gpuData:GTexture;
		
		/**
		 * Constructor.
		 * 
		 * @param	Data	A reference to a BitmapData object that will be used to populate the texture.
		 */
		public function FlxTexture(Data:BitmapData = null) 
		{
			if (Data != null)
			{
				setBitmapData(Data);
			}
		}
		
		protected function uploadBitmapDataToGPU():void
		{
			if (!FlxG.render.isBlitting())
			{
				disposeGPUData();
				// TODO: Move this texture creation to FlxRender?
				_gpuData = GTextureFactory.createFromBitmapData("FlxTexture" + Math.random(), _bitmapData);
			}
		}
		
		/**
		 * Frees the GPU memory associated with the texture. It does not
		 * free the memory occupied by the bitmapData that originated the texture.
		 */
		protected function disposeGPUData():void
		{
			if (_gpuData != null)
			{
				_gpuData.dispose();
				_gpuData = null;
			}
		}
		
		/**
		 * Frees the memory occupied by the bitmapData.
		 */
		protected function disposeBitmapData():void
		{
			if (_bitmapData != null)
			{
				_bitmapData.dispose();
				_bitmapData = null;
			}
		}
		
		/**
		 * Completly destroy the texture, freeing the GPU memory allocated to the
		 * texture and the bitmapData used to create it.
		 */
		public function destroy():void
		{
			disposeGPUData();
			_bitmapData = null;
			
			// TODO: call disposeBitmapData() here someday. In order to do that, we must know
			// if the current bitmapData is not cached by FlxG; if it is, we cannot dispose it
			// since it might be in use by another sprite.
		}
		
		/**
		 * Recycles (or creates) a new FlxTexture object with a specified width, height and color.
		 * If you specify a value for the <code>FillColor</code> parameter, every pixel in the texture
		 * (and its corresponding bitmap) is set to that color.
		 * 
		 * If the object already has an active bitmapData matching the specified parameters, it will be used to create the GPU texture.
		 * 
		 * @param	Width		The width of the sprite you want to generate.
		 * @param	Height		The height of the sprite you want to generate.
		 * @param	Color		Specifies the color of the generated block in ARGB format. The default value is 0xFFFFFFFF (solid white).
		 */
		public function makeGraphic(Width:int, Height:int, Color:uint = 4294967295):void
		{
			var regenBitmap:Boolean = true;
			
			if (_bitmapData != null)
			{
				if (_bitmapData.width == Width && _bitmapData.height == Height)
				{
					// The current bitmapData can be re-used to create the new texture.
					_bitmapData.fillRect(new Rectangle(0, 0, _bitmapData.width, _bitmapData.height), Color);
					regenBitmap = false;
				}
			}
			
			if (regenBitmap)
			{
				// TODO: there should be a param to tell the function to destroy the old bitmapData.
				_bitmapData = new BitmapData(Width, Height, false, Color);
			}

			// Free the current GPU texture and create/upload a new one.
			uploadBitmapDataToGPU();
		}
		
		/**
		 * Updates the GPU texture using the bitmapData. This method should be called every time
		 * the texture's bitmapData is changed outside the FlxTexture class, otherwise the GPU
		 * texture will remain with the pixels from the old bitmapData.
		 * 
		 * IMPORTANT: this method uploads the bitmapData to the GPU, so it drastically impacts performance.
		 * Don't use it inside a loop, for instance.
		 */
		public function markBitmapDataAsDirty():void
		{
			uploadBitmapDataToGPU();
		}
		
		/**
		 * Returns a reference to the bitmap representation of the texture.
		 */
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		/**
		 * Sets a new bitmapData. This method uploads the bitmapData to the GPU, so it drastically impacts performance.
		 * Don't use it inside a loop, for instance.
		 * 
		 * @param	New				The new bitmapData that will be used for the texture.
		 * @param	DestroyOldOne	A boolean indicating if the old bitmapData should be destroyed and freed from memory. Default is <code>false</code>.
		 */
		public function setBitmapData(New:BitmapData, DestroyOldOne:Boolean = false):void
		{
			if (New == null)
			{
				throw new UninitializedError("The new BitmapData cannot be null.");
			}
			
			if (DestroyOldOne)
			{
				disposeBitmapData();
			}
			
			_bitmapData = New;
			uploadBitmapDataToGPU();
		}
	
		/**
		 * Returns a reference to the GPU memory associated with this texture.
		 * If the current render is blitting-based, this function will always return <code>null</code>.
		 */
		public function get gpuData():GTexture
		{
			return _gpuData;
		}
	}

}