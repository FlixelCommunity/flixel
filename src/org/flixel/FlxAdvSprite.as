/**
*	Class that enables a FlxSprite to be
*	both animated and rotated by creating a baked
*	rotation sheet for each animation frame
*
*	Original concept by Simon Rozner
*	http://www.gameonaut.com/
*	http://gameonaut.com/wordpress/2011/11/flixel-demo-creating-animated-and-rotated-sprites-from-an-un-rotated-animated-images/
*
*/
package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class FlxAdvSprite extends FlxSprite
	{
		// Contains rotation sheets for each frame
		private var _rotationSheets : Vector.<BitmapData>;
		// Keep a private frame counter for now
		private var _frame : uint;
		// Number of frames the provided graphics has
		private var _frames : uint;
		// Number of rotations i.e. rotate by 360/rotations
		private var _rotations : uint;
		// Maximum dimension of each rotation sheet
		private var _sheetMaxDimension : uint;
		// Temporary clipping rectangle
		private var _advRect : Rectangle;
		// Mostly here to save memory
		private var _advPoint : Point;
		
		public function FlxAdvSprite ( SimpleGraphic:Class, rotations:uint, X:Number = 0, Y:Number = 0 )
		{
			super(X,Y,null);
			loadGraphic(SimpleGraphic,true); // Only here to get number of frames
			
			_advPoint = new Point();
			_rotationSheets = new Vector.<BitmapData>();
			_frame = 0;
			_frames = this.frames;
			_rotations = rotations;
			_sheetMaxDimension = Math.ceil( Math.sqrt( rotations ) );
			
			// Create the rotation sheets
			var bmd:BitmapData;
			for(var i:uint = 0; i < _frames; i++)
			{
				// Don't reinvent the wheel
				loadRotatedGraphic( SimpleGraphic, _rotations, i );
				// Initialize temporary container
				bmd = new BitmapData(width*_sheetMaxDimension,height*_sheetMaxDimension,true,0x00000000);
				_advRect = bmd.rect;
				// Copy current pixel data to the temporary holder and add it to the reference list
				bmd.copyPixels(_pixels,_advRect,_advPoint,_pixels,_advPoint,true);
				_rotationSheets.push(bmd);
			}
		}
		
		/**
		*	Clean up memory
		*/
		override public function destroy () : void
		{
			_rotationSheets = null;
			_frame = undefined;
			_frames = undefined;
			_rotations = undefined;
			_sheetMaxDimension = undefined;
			_advRect = null;
			_advPoint = null;
			
			super.destroy();
		}
		
		/**
		*	@override
		*/
		override public function update () : void
		{
			updateAdvancedAnimation();
			super.update();
		}
		
		/**
		*	Internal function for updating the animation
		*/
		private function updateAdvancedAnimation () : void
		{
			// We need this here out of FlxSprite for now
			if((_curAnim != null) && (_curAnim.delay > 0) && (_curAnim.looped || !finished))
			{
				_frameTimer += FlxG.elapsed;
				while(_frameTimer > _curAnim.delay)
				{
					_frameTimer = _frameTimer - _curAnim.delay;
					if(_curFrame == _curAnim.frames.length-1)
					{
						if(_curAnim.looped)
							_curFrame = 0;
						finished = true;
					}
					else
						_curFrame++;
					_frame = _curAnim.frames[_curFrame];
					dirty = true;
				}
			}
			
			
			
			// Clear out pixels
			_pixels.fillRect(_advRect,0x00000000);
			// Copy current frame to buffer
			_pixels.copyPixels(_rotationSheets[_frame],_advRect,_advPoint,_rotationSheets[_frame],_advPoint,true);
		}
	}
}