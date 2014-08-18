package flixel.system.render 
{
	import flixel.FlxGame;
	import flixel.FlxState;
	
	/**
	 * TODO: add docs
	 * @author Dovyski
	 */
	public interface FlxRender 
	{
		/**
		 * TODO: add docs
		 * 
		 * @param	Game
		 * @param	StartGameCallback
		 */
		function init(Game:FlxGame, UpdateCallback:Function):void;
		
		/**
		 * TODO: add docs
		 * 
		 * @param	State
		 */
		function draw(State:FlxState):void;
	}
}