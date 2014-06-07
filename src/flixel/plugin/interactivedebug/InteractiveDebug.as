package flixel.plugin.interactivedebug
{
	import flixel.*;
	import flixel.plugin.FlxPlugin;
	import flixel.plugin.interactivedebug.tools.Pointer;
	
	/**
	 * A plugin to visually and interactively debug a game while it is running.
	 * 
	 * @author	Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class InteractiveDebug implements FlxPlugin
	{
		private var mToolsPanal :ToolsPanel;
		
		public function InteractiveDebug()
		{		
			mToolsPanal = new ToolsPanel();
			mToolsPanal.x = FlxG.debugger.overlays.width - 15;
			mToolsPanal.y = 150;
			
			FlxG.debugger.overlays.addChild(mToolsPanal);
			
			mToolsPanal.addTool(new Pointer());
			mToolsPanal.addTool(new Pointer());
			mToolsPanal.addTool(new Pointer());
			
			// Tell Flixel to invoke the draw() method after the current
			// state has been drawn on the screen.
			FlxG.signals.postDraw.add(draw);
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			super.destroy();
		}
		
		/**
		 * Called after the game state has been drawn.
		 */
		public function draw():void
		{
			if(!FlxG.visualDebug)
				return;	
		}
	}
}
