package flixel.plugin.interactivedebug.tools
{
	import flash.display.*;
	import flixel.FlxBasic;
	import flixel.FlxG;
	import flixel.FlxGroup;
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
				
				item = pinpointItemInGroup(FlxG.state.members, mouse);
				
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
		
		private function pinpointItemInGroup(Members:Array,Cursor:FlxPoint):FlxBasic
		{
			var i:uint = 0;
			var l:uint = Members.length;
			var b:FlxBasic;
			var target:FlxBasic;
			
			while (i < l)
			{
				b = Members[i++];

				if (b != null)
				{
					if (b is FlxGroup)
					{
						target = pinpointItemInGroup((b as FlxGroup).members, Cursor);
					}
					else if((b is FlxSprite) && (b as FlxSprite).overlapsPoint(Cursor, true))
					{
						target = b;
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
