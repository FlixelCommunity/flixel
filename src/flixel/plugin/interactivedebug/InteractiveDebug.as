package flixel.plugin.interactivedebug
{
	import flash.display.Graphics;
	import flixel.*;
	import flixel.plugin.FlxPlugin;
	import flixel.plugin.interactivedebug.tools.Pointer;
	import flixel.ui.FlxText;
	import flixel.util.FlxPoint;
	import flixel.util.FlxU;
	
	/**
	 * A plugin to visually and interactively debug a game while it is running.
	 * 
	 * @author	Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class InteractiveDebug implements FlxPlugin
	{
		private var _toolsPanel :ToolsPanel;
		private var _selectedItems :FlxGroup;
		private var _label :FlxText;
		
		public function InteractiveDebug()
		{		
			// Add the panel where all tools will be contained
			_toolsPanel = new ToolsPanel();
			_toolsPanel.x = FlxG.debugger.overlays.width - 15;
			_toolsPanel.y = 150;
			
			FlxG.debugger.overlays.addChild(_toolsPanel);
			
			// Initialize internal strucutres
			_selectedItems = new FlxGroup();
			_label = new FlxText(0, 0, 200);
			_label.color = 0xffff0000;
			_label.scrollFactor.x = 0;
			_label.scrollFactor.y = 0;
			
			// Add all interactive debug tools (pointer, eraser, etc)
			addTools();
			
			// Subscrite to some Flixel signals
			FlxG.signals.postDraw.add(postDraw);
			FlxG.signals.preUpdate.add(preUpdate);
		}
		
		private function addTools():void
		{
			_toolsPanel.addTool(new Pointer(this));
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			super.destroy();
		}
		
		/**
		 * Called before the game gets updated.
		 */
		private function preUpdate():void
		{
			_toolsPanel.update();
		}
		
		/**
		 * Called after the game state has been drawn.
		 */
		private function postDraw():void
		{
			var i:uint = 0;
			var l:uint = _selectedItems.members.length;
			var item:FlxSprite;
			
			//Set up our global flash graphics object to draw out the debug stuff
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();

			while (i < l)
			{
				item = _selectedItems.members[i++];
				if (item != null && item.onScreen(FlxG.camera))
				{
					// Render a red rectangle centered at the selected item
					gfx.lineStyle(2, 0xff0000);
					gfx.drawRect(item.x - FlxG.camera.scroll.x, item.y - FlxG.camera.scroll.y, item.width * 1.3, item.height * 1.3);
					
					// Position the label above the selected item and show
					// its class name.
					_label.x = item.x - FlxG.camera.scroll.x
					_label.y = item.y - FlxG.camera.scroll.y - 10;
					_label.text = FlxU.getClassName(item);
					_label.draw();
				}
			}
			
			// Draw the rectangles to the main camera buffer.
			FlxG.camera.buffer.draw(FlxG.flashGfxSprite);
		}
		
		public function get selectedItems():FlxGroup { return _selectedItems; }
	}
}
