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

		public function FlxSignals()
		{
			reset = new FlxSignal();
		}
	}
}
