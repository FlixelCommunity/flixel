package flixel.system.render 
{
	import flixel.FlxGame;
	
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
	}
}