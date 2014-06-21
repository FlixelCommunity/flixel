package flixel.system.debug 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Parent for debugger toolbars
	 * 
	 * @author greysondn
	 * @author Adam Atomic
	 */
	public class FlxToolbar extends Sprite 
	{
		
		public function FlxToolbar() 
		{
			super();	
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			// remove this object's mouse listeners from parent
			if (parent)
			{
				parent.removeEventListener(MouseEvent.MOUSE_MOVE,handleMouseMove);
				parent.removeEventListener(MouseEvent.MOUSE_DOWN,handleMouseDown);
				parent.removeEventListener(MouseEvent.MOUSE_UP,handleMouseUp);
			}
		}
		
		/**
		 * Override to implement logic to check which button the mouse is over (if any)
		 * and handle any special logic you'd like to implement upon that.
		 * 
		 * Note that the default implementation returns false. Always.
		 */
		protected function checkOver():Boolean
		{
			// pass, basically
			return false;
		}		
		
		/**
		 * Override to implement highlighting of buttons based upon which the mouse is over.
		 */
		protected function updateGUI():void
		{
			// pass
		}
		
		/**
		 * Mark buttons as unpressed, check which buttons the mouse is over,
		 * and update highlight and GUI accordingly.
		 * 
		 * Note that this only consolidates three commonly called functions into
		 * one. It is equivalent to calling:
		 *	* unpress();
		 * 	* checkOver();
		 * 	* updateGUI();
		 */
		protected function updateGUIFromMouse():void
		{
			unpress();
			checkOver();
			updateGUI();
		}
		
		/**
		 * Override this function to reset any variables set when a button
		 * is pressed to their default "unpressed" value.
		 */
		protected function unpress():void
		{
			// pass
		}
		
		//***EVENT HANDLERS***//
		
		/**
		 * Just sets up basic mouse listeners, a la FlxWindow.
		 * 
		 * @param	E	Flash event.
		 */
		protected function init(E:Event=null):void
		{
			if(root == null)
				return;
			removeEventListener(Event.ENTER_FRAME,init);
			
			parent.addEventListener(MouseEvent.MOUSE_MOVE,handleMouseMove);
			parent.addEventListener(MouseEvent.MOUSE_DOWN,handleMouseDown);
			parent.addEventListener(MouseEvent.MOUSE_UP,handleMouseUp);
		}
		
		/**
		 * If the mouse moves, check to see if any buttons should be highlighted.
		 * 
		 * @param	E	Flash mouse event.
		 */
		protected function handleMouseMove(E:MouseEvent=null):void
		{
			if(!checkOver())
				unpress();
			updateGUI();
		}
		
		/**
		 * Override to check if a specific button is pressed down.
		 * 
		 * @param	E	Flash mouse event.
		 */
		protected function handleMouseDown(E:MouseEvent=null):void
		{
			unpress();
		}
		
		/**
		 * Override to check if mouse was released over a pressed button.
		 * 
		 * @param	E	Flash mouse event
		 */
		protected function handleMouseUp(E:MouseEvent=null):void
		{
			// pass
		}
	}

}