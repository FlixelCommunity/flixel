package flixel.util
{
	/**
	 * A class describing a signal.
	 * 
	 * @see FlxSignals
	 * @author	Fernando Bevilacqua (Dovyski)
	 */
	public class FlxSignal
	{
		/**
		 * List of all subscribers that this signal has.
		 */
		private var subscribers :Vector.<Function>;
		
		public function FlxSignal()
		{
			subscribers = new Vector.<Function>();
		}
		
		/**
		 * Adds a subscriber to this signal. If the callback being added is already in the list of subscribers, it will not added again.
		 * 
		 * @param	Callback	Callback invoked when the signal is dispatched. The callback must have the structure <code>function name():void</code>.
		 * @return	<code>true</code> if the callback was successfully added, or <code>false</code> if it was not added, which means the callback was already in the list of subscribers.
		 */
		public function add(Callback :Function) :Boolean
		{
			var added :Boolean = false;

			if (Callback != null && has(Callback) == false)
			{
				subscribers.push(Callback);
				added = true;
			}
			
			return added;
		}
		
		/**
		 * Removes a subscriber from this signal.
		 * 
		 * @param	Callback	The callback to be removed from the list of subscribers.
		 * @return	<code>true</code> if the callback existed in the list of subscribers and was removed, or <code>false</code> otherwise (it didn't exist in the list of subscribers).
		 */
		public function remove(Callback :Function) :Boolean
		{
			var index :int;
			
			if (Callback != null)
			{
				index = subscribers.indexOf(Callback);
				
				if (index != -1) {
					subscribers.splice(index, 1);
				}
			}
			
			return index != -1;
		}
		
		/**
		 * Removes all subcribers from this signal.
		 */
		public function removeAll() :void
		{
			subscribers.length = 0;
		}
		
		/**
		 * Checks if this signal has an specific subscriber.
		 * 
		 * @param	Callback	The callback that the method will search for in the list of subscribers.
		 * @return	<code>true</code> if the list of subscribers has the specified callback, or <code>false</code> otherwise.
		 */
		public function has(Callback :Function) :Boolean
		{
			return subscribers.indexOf(Callback) != -1;
		}
		
		/**
		 * Dispatches this signal to subscribers by invoking all callbackes in the list of subcribers.
		 */
		public function dispatch() :void
		{
			var i :int, l :int = subscribers.length;
			
			for (i = 0; i < l; i++)
			{
				if (subscribers[i] != null)
				{
					subscribers[i]();
				}
			}
		}
		
		/**
		 * Clean up memory and destroys the signal.
		 */
		public function destroy():void
		{
			subscribers.length = 0;
			subscribers = null;
		}
	}
}