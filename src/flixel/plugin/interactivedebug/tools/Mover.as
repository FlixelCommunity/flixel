package flixel.plugin.interactivedebug.tools
{
	import flixel.*;
	import flixel.plugin.interactivedebug.InteractiveDebug;
	import flixel.util.FlxPoint;
	
	/**
	 * A tool to move selected items.
	 * 
	 * @author Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class Mover extends Tool
	{		
		[Embed(source="../../../assets/vis/bounds.png")] protected var ImgBounds:Class;

		private var _dragging:Boolean;
		private var _lastCursorPosition:FlxPoint;
		
		public function Mover(Brain:InteractiveDebug)
		{
			super(Brain);
			icon = new ImgBounds();
			addChild(icon);
			
			_dragging = false;
			_lastCursorPosition = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		override public function update():void 
		{
			super.update();
			
			if (FlxG.mouse.justPressed() && !_dragging)
			{
				startDragging();
			}
			else if (FlxG.mouse.pressed() && _dragging)
			{
				doDragging();
			}
			else if (FlxG.mouse.justReleased())
			{
				stopDragging();
			}
			
			_lastCursorPosition.x = FlxG.mouse.x;
			_lastCursorPosition.y = FlxG.mouse.y;
		}
		
		private function doDragging():void
		{
			var i:uint;
			var members:Array = brain.selectedItems.members;
			var l:uint = members.length;
			var item:FlxObject;
			var dx:Number = FlxG.mouse.x - _lastCursorPosition.x;
			var dy:Number = FlxG.mouse.y - _lastCursorPosition.y;
			
			while (i < l)
			{
				item = members[i++];
				if (item != null)
				{
					item.x += dx;
					item.y += dy;
				}
			}
		}
		
		private function startDragging():void
		{
			_dragging = true;	
		}
		
		private function stopDragging():void
		{
			_dragging = false;
		}
	}
}
