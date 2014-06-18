package flixel.plugin.interactivedebug.tools
{
	import flash.display.*;
	import flixel.plugin.interactivedebug.InteractiveDebug;
	
	/**
	 * The base class of all tools in the interactive debug. 
	 * 
	 * @author Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class Tool extends Sprite
	{		
		public var icon:Bitmap;
		public var brain:InteractiveDebug;
		
		public function Tool(Brain:InteractiveDebug)
		{
			brain = Brain;
		}
		
		public function update():void
		{
			
		}
		
		public function draw():void
		{
			
		}
		
		public function activate():void
		{
		}
		
		public function deactivate():void
		{
		}
	}
}
