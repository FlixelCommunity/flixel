package flixel.plugin.interactivedebug
{
	import flash.display.Graphics;
	import flixel.*;
	import flixel.plugin.FlxPlugin;
	import flixel.plugin.interactivedebug.tools.*;
	import flixel.ui.FlxText;
	import flixel.util.*;
	
	/**
	 * A plugin to visually and interactively debug a game while it is running.
	 * 
	 * TODO:
	 * - Make Tool#init(brain) instead of passing that in the constructor
	 * - Make tools setIcon() instead of using _icon or something
	 * - Move _selectedItems from brain to Pointer tool (make tools able to communicate with brain.getTool(Class).
	 * - Create update/draw methods for tools?
	 * - Add signals to tools, so Pointer can dispatch when an item was selected?
	 * - Make ToolsPanel only contain the tool icons, not the tools itself, it should be the brain's responsability
	 * 
	 * @author	Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class InteractiveDebug implements FlxPlugin
	{
		private var _toolsPanel :ToolsPanel;
		private var _tools:Array;
		
		public function InteractiveDebug()
		{		
			// Add the panel where all tools icons will be contained
			_toolsPanel = new ToolsPanel();
			_toolsPanel.x = FlxG.debugger.overlays.width - 15;
			_toolsPanel.y = 150;
			
			FlxG.debugger.overlays.addChild(_toolsPanel);
			
			// Add all interactive debug tools (pointer, eraser, etc)
			addTools();
			
			// Subscrite to some Flixel signals
			FlxG.signals.postDraw.add(postDraw);
			FlxG.signals.preUpdate.add(preUpdate);
		}
		
		private function addTools():void
		{
			var availableTools:Array = [
				Pointer,
				Eraser,
				Mover,
			];
			var tool:Tool;
			var i:uint;
			
			_tools = [];
			
			for (i = 0; i < availableTools.length; i++)
			{
				tool = (new availableTools[i]).init(this);
				_tools.push(tool);
				
				// If the tool has an icon, it should be displayed in
				// the tools panel (right of the screen).
				if (tool.icon != null)
				{
					_toolsPanel.addTool(tool);
				}
			}
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			super.destroy();
			// TODO: remove all entities and free memory.
		}
		
		/**
		 * Called before the game gets updated.
		 */
		private function preUpdate():void
		{
			var tool:Tool;
			var i:uint;
			var l:uint = _tools.length;
			
			for (i = 0; i < l; i++)
			{
				tool = _tools[i];
				tool.update();
			}
		}
		
		/**
		 * Called after the game state has been drawn.
		 */
		private function postDraw():void
		{
			var tool:Tool;
			var i:uint;
			var l:uint = _tools.length;
			
			for (i = 0; i < l; i++)
			{
				tool = _tools[i];
				tool.draw();
			}
		}
		
		public function getTool(ClassName:Class):Tool
		{
			var tool:Tool;
			var i:uint;
			var l:uint = _tools.length;
			
			for (i = 0; i < l; i++)
			{
				if (_tools[i] is ClassName)
				{
					tool = _tools[i];
					break;
				}
			}
			
			return tool;
		}
	}
}
