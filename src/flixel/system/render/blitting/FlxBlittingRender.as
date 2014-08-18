package flixel.system.render.blitting 
{
	import flash.events.Event;
	import flixel.*;
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
		
		public function draw(State:FlxState):void
		{
			lockCameras();
			State.draw();
			unlockCameras();
		}
		
		/**
		 * Called by the game object to lock all the camera buffers and clear them for the next draw pass.
		 */
		private function lockCameras():void
		{
			var cam:FlxCamera;
			var cams:Array = FlxG.cameras;
			var i:uint = 0;
			var l:uint = cams.length;
			while(i < l)
			{
				cam = cams[i++] as FlxCamera;
				if((cam == null) || !cam.exists || !cam.visible)
					continue;
				if(FlxG.useBufferLocking)
					cam.buffer.lock();
				cam.fill(cam.bgColor);
				cam.screen.dirty = true;
			}
		}
		
		/**
		 * Called by the game object to draw the special FX and unlock all the camera buffers.
		 */
		private function unlockCameras():void
		{
			var cam:FlxCamera;
			var cams:Array = FlxG.cameras;
			var i:uint = 0;
			var l:uint = cams.length;
			while(i < l)
			{
				cam = cams[i++] as FlxCamera;
				if((cam == null) || !cam.exists || !cam.visible)
					continue;
				cam.drawFX();
				if(FlxG.useBufferLocking)
					cam.buffer.unlock();
			}
		}
	}
}