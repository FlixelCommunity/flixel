package flixel.system
{
	import flixel.util.FlxSignal;
	
	/**
	 * A class containing an entry for every signal dispatched by Flixel.
	 * 
	 * A signal can be seen as an event and it is dispatched by Flixel at specific points
	 * in the code. For instance when Flixel is about to switch the current state, it will dispatch
	 * a signal informting about it. Objects can subscribe to signals in order to receive a notification
	 * when the mentioned signal is dispatched.
	 * 
	 * In order to subscribe to any signal, all you have to do is add a callback function to the signal
	 * dispatcher using its <code>add()</code> method. For instance, you can subscribe to the
	 * <code>beforeStateSwitch</code> signal as follows:
	 * 
	 * <code>
	 * FlxG.signals.beforeStateSwitch.add(myCallback);
	 * 
	 * function myCallback():void {
	 * 		FlxG.log("Flixel is about to switch the current state!");
	 * }
	 * </code>
	 * 
	 * In order to cancel the subscription, just call <code>remove()</code> on the signal:
	 * 
	 * <code>
	 * FlxG.signals.beforeStateSwitch.remove(myCallback);
	 * </code>
	 * 
	 * Inspect this class to learn about all the available signals.
	 * 
	 * @see FlxSignal
	 * @author Fernando Bevilacqua (Dovyski)
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
