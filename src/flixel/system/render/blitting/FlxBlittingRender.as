package flixel.system.render.blitting 
{
	import flixel.FlxGame;
	import flixel.system.render.FlxRender;
	
	/**
	 * TODO: add docs
	 * @author Dovyski
	 */
	public class FlxBlittingRender extends FlxRender
	{
		
		public function FlxBlittingRender(Game:FlxGame, StartGameCallback:Function) 
		{
			super(Game, StartGameCallback);
			
			// Nothing to init here, just tell Flixel the render is ready to roll!
			StartGameCallback();
		}
	}
}