package flixel.plugin.interactivedebug.tools
{
	import flash.display.*;
	import flixel.FlxBasic;
	import flixel.FlxG;
	import flixel.FlxSprite;
	import flixel.FlxState;
	import flixel.plugin.interactivedebug.InteractiveDebug;
	import flixel.util.FlxPoint;
	
	/**
	 * A tool to use the mouse cursor to select game elements.
	 * 
	 * @author Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class Pointer extends Tool
	{		
		[Embed(source="../../../assets/vis/bounds.png")] protected var ImgBounds:Class;
		
		private var mouse:FlxPoint;
		
		public function Pointer(Brain:InteractiveDebug)
		{
			super(Brain);
			icon = new ImgBounds();
			addChild(icon);
			
			mouse = new FlxPoint();
		}
		
		override public function update():void 
		{
			var item :FlxBasic;
			super.update();
			
			if (FlxG.mouse.justPressed())
			{
				mouse.x = FlxG.mouse.x;
				mouse.y = FlxG.mouse.y;
				
				item = getGameItemAt(mouse);
				
				if (item != null)
				{
					handleItemClick(item);
				}
			}
		}
		
		private function handleItemClick(Item:FlxBasic):void
		{
			FlxG.log("handleItemClick("+Item+")");
			brain.selectedItems.add(Item);
		}
		
		private function getGameItemAt(Cursor:FlxPoint):FlxBasic
		{
			var i:uint = 0;
			var members:Array = FlxG.state.members;
			var l:uint = members.length;
			var b:FlxBasic;
			var target:FlxBasic;
			
			while (i < l)
			{
				b = members[i++];
				
				// TODO: improve this test. Check for other types besides FlxSprite
				if (b != null && (b is FlxSprite) && (b as FlxSprite).overlapsPoint(Cursor, true))
				{
					target = b;
					break;
				}
			}
			
			return target;
		}
	}
}
