package flixel.plugin.interactivedebug.tools
{
	import flixel.*;
	import flixel.plugin.interactivedebug.InteractiveDebug;
	import flixel.tile.FlxTilemap;
	import flixel.util.FlxPoint;
	
	/**
	 * A tool to edit tilemaps. 
	 * TODO: make a nice dialog to select which tilemap to edit
	 * 
	 * @author Fernando Bevilacqua (dovyski@gmail.com)
	 * @copyright I got several ideas from here: https://github.com/LordTim/FlxTilemap-Demo
	 */
	public class Tile extends Tool
	{		
		[Embed(source="../assets/tile.png")] protected var ImgTile:Class;

		private var _tileHightligh:FlxSprite;
		
		public function Tile()
		{
			setClickableIcon(new ImgTile());
			
			// TODO: get tile width/height from selected tilemap
			_tileHightligh = new FlxSprite();
			_tileHightligh.makeGraphic(16, 16, 0xffff0000);
			_tileHightligh.width = 8;
			_tileHightligh.height = 8;
		}
		
		override public function update():void 
		{
			super.update();
			
			_tileHightligh.x = Math.floor(FlxG.mouse.x / _tileHightligh.width) * _tileHightligh.width;
			_tileHightligh.y = Math.floor(FlxG.mouse.y / _tileHightligh.height) * _tileHightligh.height;
			
			if (FlxG.mouse.pressed())
			{
				var tilemap:FlxTilemap = getFirstTilemap(FlxG.state.members);
				if (tilemap != null)
				{
					tilemap.setTile(FlxG.mouse.x / _tileHightligh.width, FlxG.mouse.y / _tileHightligh.height, FlxG.keys.SHIFT ? 0 : 1);
				}
			}
		}
		
		override public function draw():void 
		{
			_tileHightligh.drawDebug();
		}
		
		// TODO: improve this method and move it to the Brain?
		private function getFirstTilemap(Members:Array):FlxTilemap
		{
			var i:uint = 0;
			var l:uint = Members.length;
			var b:FlxBasic;
			var target:FlxTilemap;
			
			while (i < l)
			{
				b = Members[i++];

				if (b != null)
				{
					if (b is FlxGroup)
					{
						target = getFirstTilemap((b as FlxGroup).members);
					}
					else if(b is FlxTilemap)
					{
						target = b as FlxTilemap;
					}
					if (target != null)
					{
						break;
					}
				}
			}
			
			return target;
		}
	}
}
