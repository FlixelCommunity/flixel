package org.flixel.system
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * Generic toolbar for flixel's system tools. This is largely a refactoring
	 * of Vis and VCR's common traits into a single class. Adam is credited for
	 * the original code, which was reorganized and copy/pasted here, largely.
	 *
	 * I realize a lot of this is made for override. What this means is that
	 * extending classes must examine unpress(),
	 *
	 * @author Adam Atomic
	 * @author greysondn
	 */
	
	public class FlxToolbar extends Sprite
	{
		public function FlxToolbar()
		{
			// does a lot of nothing for now.
		}
		
		/**
		 * Clears the listing of where the mouse is, checks what it is currently
		 * over, and updates the gui accoridingly. Compound function call,
		 * executes:
		 * 		unpress();
		 *		checkOver();
		 *		updateGUI();
		 */
		protected function updateGUIFromMouse():void
		{
			// mark all buttons as no longer pressed.
			unpress();
			
			// check what the mouse is currently over.
			checkOver();
			
			// update the GUI accordingly.
			updateGUI();
		}
		
		/**
		 * Override to check whether a mouse is over any buttons or
		 * not.
		 *
		 * @return	Boolean	true if mouse was over a button
		 * 					false if it wasn't
		 */
		protected function checkOver():Boolean
		{
			// deliberate pass, return false as a one-off
			return false;
		}
		
		/**
		 * Override to match:
		 *
		 * Figures out what buttons to highlight based on the _overWhatever and _pressingWhatever variables.
		 *
		 * TODO: clean up documentation.
		 */
		protected function updateGUI():void
		{
			// deliberate pass
		}
		
		/**
		 * Override and use to set all pressed state variables for buttons
		 * to false.
		 */
		protected function unpress():void
		{
			// deliberate pass
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
		
		protected function handleMouseUp(E:MouseEvent = null):void
		{
			// deliberate pass
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
		 * Overrride this function and make a call to parent to implement
		 * checking if the user has pressed down a specific button.
		 *
		 *
		 * @param	E	Flash mouse event.
		 */
		protected function handleMouseDown(E:MouseEvent=null):void
		{
			// only common line of code in originals ~greysondn, 7 Mar 2013
			unpress();
		}
		
		
	}

}