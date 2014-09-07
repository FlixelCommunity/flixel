package flixel.tile
{
	import com.genome2d.textures.factories.GTextureFactory;
	import com.genome2d.textures.GTexture;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flixel.system.render.genome2d.FlxGenome2DRender;
	
	import flixel.FlxG;
	import flixel.FlxCamera;
	import flixel.util.FlxMath;

	/**
	 * A helper object to keep tilemap drawing performance decent across the new multi-camera system.
	 * Pretty much don't even have to think about this class unless you are doing some crazy hacking.
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxTilemapBuffer
	{
		/**
		 * The current X position of the buffer.
		 */
		public var x:Number;
		/**
		 * The current Y position of the buffer.
		 */
		public var y:Number;
		/**
		 * The width of the buffer (usually just a few tiles wider than the camera).
		 */
		public var width:Number;
		/**
		 * The height of the buffer (usually just a few tiles taller than the camera).
		 */
		public var height:Number;
		/**
		 * Whether the buffer needs to be redrawn.
		 */
		public var dirty:Boolean;
		/**
		 * How many rows of tiles fit in this buffer.
		 */
		public var rows:uint;
		/**
		 * How many columns of tiles fit in this buffer.
		 */
		public var columns:uint;

		protected var _pixels:BitmapData;	
		protected var _flashRect:Rectangle;
		
		/**
		 * TODO: Render: add docs
		 */
		protected var _queue :Array;
		protected var _queueSize :uint;
		protected var _tiles :BitmapData;
		protected var _texture :GTexture; // TODO: remove this?
		protected var _point :Point;

		/**
		 * Instantiates a new camera-specific buffer for storing the visual tilemap data.
		 *  
		 * @param Tiles			TODO: Render: add docs
		 * @param TileWidth		The width of the tiles in this tilemap.
		 * @param TileHeight	The height of the tiles in this tilemap.
		 * @param WidthInTiles	How many tiles wide the tilemap is.
		 * @param HeightInTiles	How many tiles tall the tilemap is.
		 * @param Camera		Which camera this buffer relates to.
		 */
		public function FlxTilemapBuffer(Tiles:BitmapData,TileWidth:Number,TileHeight:Number,WidthInTiles:uint,HeightInTiles:uint,Camera:FlxCamera=null)
		{
			var i:int = 0, l:int;
			
			if(Camera == null)
				Camera = FlxG.camera;

			columns = FlxMath.ceil(Camera.width/TileWidth)+1;
			if(columns > WidthInTiles)
				columns = WidthInTiles;
			rows = FlxMath.ceil(Camera.height/TileHeight)+1;
			if(rows > HeightInTiles)
				rows = HeightInTiles;
			
			_pixels = new BitmapData(columns*TileWidth,rows*TileHeight,true,0); // TODO: Render: this is no longer necessary, but it might have a better performance on blitting render.
			width = _pixels.width;
			height = _pixels.height;			
			_flashRect = new Rectangle(0,0,width,height);
			dirty = true;
			
			// TODO: Render: add docs
			l = rows * columns;
			_queue = new Array(l);
			while (i < l)
			{
				_queue[i++] = { 'flashRect': new Rectangle(), 'flashPoint': new Point(), 'texture': null };
			}
			_queueSize = 0;
			
			_tiles = Tiles;
			_point = new Point();
			if (FlxG.render is FlxGenome2DRender)
			{
				_texture = GTextureFactory.createFromBitmapData("tiles" + Math.random(), _tiles);
			}
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			_pixels = null;
		}
		
		/**
		 * Fill the buffer with the specified color.
		 * Default value is transparent.
		 * 
		 * @param	Color	What color to fill with, in 0xAARRGGBB hex format.
		 */
		public function fill(Color:uint=0):void
		{
			// TODO: check if this fillRect is really necessary.
			if (_pixels != null)
			{
				_pixels.fillRect(_flashRect, Color);
			}
			_queueSize = 0;
		}
		
		/**
		 * Read-only, nab the actual buffer <code>BitmapData</code> object.
		 * TODO: Render: change Texture:Object to Texture:FlxTexture
		 * 
		 * @return	The buffer bitmap data.
		 */
		public function enqueue(FlashRect:Rectangle, FlashPoint:Point, Texture:Object = null):void
		{
			_queue[_queueSize].flashRect.x = FlashRect.x;
			_queue[_queueSize].flashRect.y = FlashRect.y;
			_queue[_queueSize].flashRect.width = FlashRect.width;
			_queue[_queueSize].flashRect.height = FlashRect.height;
			
			_queue[_queueSize].flashPoint.x = FlashPoint.x;
			_queue[_queueSize].flashPoint.y = FlashPoint.y;
			
			_queue[_queueSize].texture = Texture;
			
			_queueSize++;
		}
		
		/**
		 * Just stamps this buffer onto the specified camera at the specified location.
		 * 
		 * @param	Camera		Which camera to draw the buffer onto.
		 * @param	FlashPoint	Where to draw the buffer at in camera coordinates.
		 */
		public function draw(Camera:FlxCamera,FlashPoint:Point):void
		{
			var i:uint = 0;

			while (i < _queueSize)
			{
				_point.x = FlashPoint.x + _queue[i].flashPoint.x;
				_point.y = FlashPoint.y + _queue[i].flashPoint.y;
				
				FlxG.render.copyPixelsToBuffer(Camera, _queue[i].texture ? _queue[i].texture.texture : _texture, _queue[i].texture ? _queue[i].texture.bitmapData : null, _queue[i].flashRect, _point, null, null, true);
				
				i++;
			}
		}
	}
}