package flixel.system
{
	import flixel.util.FlxSignal;
	
	/**
	 * TODO: add docs.
	 */
	public class FlxSignals
	{
		/**
		 * Dispatched when the game is reset by <code>FlxG.resetGame()</code>.
		 */
		public var reset:FlxSignal;
		
		/**
		 * Dispatched when the current state is about to be replaced by a new one.
		 * The switch is a result of <code>FlxG.switchState()</code>. When this signal
		 * is dispatched, the current state is still active (it's about to be destroyed)
		 * and the new state is already instantiated.
		 */
		public var beforeStateSwitch:FlxSignal;
		
		/**
		 * Dispatched when Flixel is about to update the current game state and its children.
		 * It may be called multiple times per "frame".
		 */
		public var preUpdate:FlxSignal;
		
		/**
		 * Dispatched after Flixel has drawn the current state on the screen.
		 */
		public var postDraw:FlxSignal;

		public function FlxSignals()
		{
			reset = new FlxSignal();
			beforeStateSwitch = new FlxSignal();
			preUpdate = new FlxSignal();
			postDraw = new FlxSignal();
		}
	}
}
