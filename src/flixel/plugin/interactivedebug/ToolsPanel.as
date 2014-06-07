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
			tool.clicked();
			
			setAsActive(tool);
		}
		
		protected function setAsActive(Item:Tool):void
		{
			Item.icon.scaleX = 1.1;
			Item.icon.scaleY = 1.1;
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			// TODO: implement this method.
		}
	}
}
