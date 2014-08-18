package flixel.system.render.blitting 
{
	import flash.events.Event;
	import flixel.FlxGame;
	import flixel.system.render.FlxRender;
	
	/**
	 * TODO: add docs
	 * @author Dovyski
	 */
	public class FlxBlittingRender implements FlxRender
	{
		public function init(Game:FlxGame, UpdateCallback:Function):void 
		{
			Game.stage.addEventListener(Event.ENTER_FRAME, UpdateCallback);
		}
	}
}