package flixel.plugin.interactivedebug.tools
{
	import flash.display.*;
	
	/**
	 * A tool to use the mouse cursor to select game elements.
	 * 
	 * @author Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class Pointer extends Tool
	{		
		[Embed(source="../../../assets/vis/bounds.png")] protected var ImgBounds:Class;
		
		public function Pointer()
		{
			super();
			icon = new ImgBounds();
			addChild(icon);
		}
	}
}
