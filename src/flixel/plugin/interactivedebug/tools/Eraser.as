package flixel.plugin.interactivedebug.tools
{
	import flash.display.*;
	import flash.geom.Point;
	import flixel.FlxBasic;
	import flixel.FlxG;
	import flixel.FlxGroup;
	import flixel.FlxSprite;
	import flixel.FlxState;
	import flixel.plugin.interactivedebug.InteractiveDebug;
	import flixel.util.FlxPoint;
	
	/**
	 * A tool to delete items from the screen.
	 * 
	 * @author Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class Eraser extends Tool
	{		
		[Embed(source="../../../assets/vis/bounds.png")] protected var ImgBounds:Class;
		
		public function Eraser()
		{
			setClickableIcon(new ImgBounds());
		}
		
		override public function update():void 
		{
			var selectedItems :FlxGroup = findSelectedItemsByPointer();
			
			super.update();
			
			if (FlxG.keys.justPressed("DELETE") && selectedItems != null)
			{
				findAndDelete(selectedItems, FlxG.keys.pressed("SHIFT"));
				selectedItems.clear();
			}
		}
		
		private function findAndDelete(Items:FlxGroup, RemoveFromMemory:Boolean = false):void
		{
			var i:int = 0;
			var members:Array = Items.members;
			var l:int = members.length;
			var item:FlxBasic;
			
			while (i < l)
			{
				item = members[i++];
				
				if (item != null)
				{
					if (item is FlxGroup)
					{
						// TODO: walk in the group, removing all members.
					}
					else
					{
						item.kill();
						
						if (RemoveFromMemory)
						{
							removeFromMemory(item, FlxG.state);
						}
					}
				}
			}
		}
		
		private function removeFromMemory(Item:FlxBasic, ParentGroup:FlxGroup):void
		{
			var i:uint = 0;
			var members:Array = ParentGroup.members;
			var l:uint = members.length;
			var b:FlxBasic;
			
			while (i < l)
			{
				b = members[i++];

				if (b != null)
				{
					if (b is FlxGroup)
					{
						removeFromMemory(Item, b as FlxGroup);
					}
					else if(b == Item)
					{
						ParentGroup.remove(b);
						FlxG.log("Deleted:" + ParentGroup + "::" + Item);
					}
				}
			}
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
		
		private function findSelectedItemsByPointer():FlxGroup
		{
			var tool:Pointer = brain.getTool(Pointer) as Pointer;
			return tool != null ? tool.selectedItems : null;
		}
	}
}
