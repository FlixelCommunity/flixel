package flixel.system.debug
{
	import flixel.FlxG;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * This control panel has all the visual debugger toggles in it, in the debugger overlay.
	 * Currently there is only one toggle that flips on all the visual debug settings.
	 * This panel is heavily based on the VCR panel.
	 * 
	 * @author Adam Atomic
	 */
	public class Vis extends FlxToolbar
	{
		[Embed(source="../../assets/vis/bounds.png")] protected var ImgBounds:Class;

		protected var _bounds:Bitmap;
		protected var _overBounds:Boolean;
		protected var _pressingBounds:Boolean;
		
		/**
		 * Instantiate the visual debugger panel.
		 */
		public function Vis()
		{
			super();
			
			_bounds = new ImgBounds();
			addChild(_bounds);
			
			updateGUIFromMouse();
			
			addEventListener(Event.ENTER_FRAME,init);
		}
		
		/**
		 * Clean up memory.
		 */
		override public function destroy():void 
		{
			if (_bounds) removeChild(_bounds);
			_bounds = null;
			
			if (parent)
			{
				parent.removeEventListener(MouseEvent.MOUSE_MOVE,handleMouseMove);
				parent.removeEventListener(MouseEvent.MOUSE_DOWN,handleMouseDown);
				parent.removeEventListener(MouseEvent.MOUSE_UP,handleMouseUp);
			}
			
			super.destroy();
		}
		
		//***ACTUAL BUTTON BEHAVIORS***//
		
		/**
		 * Called when the bounding box toggle is pressed.
		 */
		public function onBounds():void
		{
			FlxG.visualDebug = !FlxG.visualDebug;
		}
		
		//***EVENT HANDLERS***//
		
		/**
		 * If the mouse is pressed down, check to see if the user started pressing down a specific button.
		 * 
		 * @param	E	Flash mouse event.
		 */
		override protected function handleMouseDown(E:MouseEvent = null):void 
		{
			super.handleMouseDown(E);
			
			if(_overBounds)
				_pressingBounds = true;
		}
		
		/**
		 * If the mouse is released, check to see if it was released over a button that was pressed.
		 * If it was, take the appropriate action based on button state and visibility.
		 * 
		 * @param	E	Flash mouse event.
		 */
		override protected function handleMouseUp(E:MouseEvent=null):void
		{
			super.handleMouseUp();
			
			if(_overBounds && _pressingBounds)
				onBounds();
			
			updateGUIFromMouse();
		}
		
		//***MISC GUI MGMT STUFF***//
		
		/**
		 * This function checks to see what button the mouse is currently over.
		 * Has some special behavior based on whether a recording is happening or not.
		 * 
		 * @return	Whether the mouse was over any buttons or not.
		 */
		override protected function checkOver():Boolean
		{	
			super.checkOver();
			
			_overBounds = false;
			
			if ((mouseX < 0) || (mouseX > width) || (mouseY < 0) || (mouseY > height))
			{
				return false;
			}
			
			if ((mouseX > _bounds.x) || (mouseX < _bounds.x + _bounds.width))
			{
				_overBounds = true;
			}
			
			return true;
		}
		
		/**
		 * Sets all the pressed state variables for the buttons to false.
		 */
		override protected function unpress():void 
		{
			super.unpress();
			
			_pressingBounds = false;
		}
		
		/**
		 * Figures out what buttons to highlight based on the _overWhatever and _pressingWhatever variables.
		 */
		override protected function updateGUI():void 
		{
			super.updateGUI();
			
			if(FlxG.visualDebug)
			{
				if(_overBounds && (_bounds.alpha != 1.0))
					_bounds.alpha = 1.0;
				else if(!_overBounds && (_bounds.alpha != 0.9))
					_bounds.alpha = 0.9;
			}
			else
			{
				if(_overBounds && (_bounds.alpha != 0.6))
					_bounds.alpha = 0.6;
				else if(!_overBounds && (_bounds.alpha != 0.5))
					_bounds.alpha = 0.5;
			}
		}
	}
}
