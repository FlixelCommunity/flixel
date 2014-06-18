package flixel.plugin.interactivedebug
{
	import flash.display.*;
	import flash.events.*;
	import flixel.plugin.interactivedebug.tools.*;
	
	/**
	 * A container to hold all tools related to the interactive debug.
	 * 
	 * @author Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class ToolsPanel extends Sprite
	{
		private const ALPHA_MOUSE_OVER_TOOL:Number = 1.0;
		private const ALPHA_MOUSE_OUT_TOOL:Number = 0.8;
		
		private var _offsetY :Number;
		private var _activeTool :Tool;
		
		public function ToolsPanel()
		{
			super();
			_offsetY = 0;
		}
		
		public function addTool(Instance :Tool):void
		{
			Instance.y = _offsetY;
			Instance.alpha = ALPHA_MOUSE_OUT_TOOL;
			
			addChild(Instance);
			_offsetY += Instance.height + 8;
			
			Instance.addEventListener(MouseEvent.MOUSE_OVER, mouseOverTool);
			Instance.addEventListener(MouseEvent.MOUSE_OUT, mouveOutTool);
			Instance.addEventListener(MouseEvent.CLICK, mouseClickTool);
		}
		
		protected function mouseOverTool(E:MouseEvent):void
		{
			var tool:Tool = E.currentTarget as Tool;
			tool.icon.alpha = ALPHA_MOUSE_OVER_TOOL;
		}
		
		protected function mouveOutTool(E:MouseEvent):void
		{
			var tool:Tool = E.currentTarget as Tool;
			tool.icon.alpha = ALPHA_MOUSE_OUT_TOOL;
		}
		
		protected function mouseClickTool(E:MouseEvent):void
		{
			var tool:Tool = E.currentTarget as Tool;
			setAsActive(tool);
		}
		
		protected function setAsActive(Item:Tool):void
		{
			if (_activeTool)
			{
				_activeTool.deactivate();
				changeIconStatus(Item, false);
			}
			
			if (_activeTool != Item)
			{
				changeIconStatus(Item, true);
				
				_activeTool = Item;
				_activeTool.activate();
			}
			else
			{
				_activeTool = null;
			}
		}
		
		private function changeIconStatus(Item:Tool, Status:Boolean):void
		{
			Item.icon.scaleX = Status ? 1.1 : 1.0;
			Item.icon.scaleY = Status ? 1.1 : 1.0;
			Item.icon.rotation = Status ? 5 : 0;
		}
		
		public function get activeTool():Tool
		{
			return _activeTool;
		}
	}
}
