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
		private var _icon:Bitmap;
		private var _brain:InteractiveDebug;
		private var _active:Boolean;
		
		public function Tool()
		{
		}
		
		public function init(Brain:InteractiveDebug):Tool
		{
			_active = false;
			_brain = Brain;
			return this;
		}
		
		public function update():void
		{
		}
		
		public function draw():void
		{
		}
		
		public function activate():void
		{
			_active = true;
		}
		
		public function deactivate():void
		{
			_active = false;
		}
		
		public function isActive():Boolean
		{
			return _active;
		}
		
		public function setClickableIcon(Icon:Bitmap):void
		{
			_icon = Icon;
			addChild(_icon);
		}
		
		public function get icon():Bitmap
		{
			return _icon;
		}
		
		public function get brain():InteractiveDebug
		{
			return _brain;
		}
	}
}
