package flixel.util
{
	/**
	 * TODO: write docs.
	 */
	public class FlxSignal
	{
		private var subscribers :Vector.<Function>;
		
		public function FlxSignal()
		{
			subscribers = new Vector.<Function>();
		}
		
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
		
		public function removeAll() :void
		{
			subscribers.length = 0;
		}
		
		public function has(Callback :Function) :Boolean
		{
			return subscribers.indexOf(Callback) != -1;
		}
		
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
		 * Clean up memory.
		 */
		public function destroy():void
		{
			subscribers.length = 0;
			subscribers = null;
		}
	}
}