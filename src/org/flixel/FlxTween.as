package org.flixel
{	
	/**
	 * Simple class for tweening a simple numerical value from one point to another.
	 * For more complex operations, please use a dedicated library such as TweenMax.
	 *
	 * This class does not use the "global" time to progress the tween, but must 
	 * manually be incremented with the `progress` property.
	 * 
	 * @author	Andreas Renberg (IQAndreas)
	 */
	public class FlxTween
	{
	
		/**
		 * Instantiate a new tween object.
		 *
		 * @param StartValue	The starting value.
		 * @param EndValue	The end value.
		 * @param Duration	The total duration of the tween.
		 * @param Ease	The easing function used by the tween. Any tweening function from TweenMax library or the `fl.transitions.easing` package can be used. Defaults to `FlxTween.linear`.
		 */
		public function FlxTween(StartValue:Number, EndValue:Number, Duration:Number, Ease:Function = null)
		{
			easingFunction = (Ease != null) ? Ease : FlxTween.linear;
		
			//TODO: Verify perameters (such as negative duration, invalid start or end values, etc)
			startValue = StartValue;
			totalChange = EndValue - StartValue;
			duration = Duration;
			
			_progress = 0;
		}

		/**
		 * The easing function used by the Tween.
		 */
		protected var easingFunction:Function;
		/**
		 * Internal tracker for the start value of the tween.
		 */
		protected var startValue:Number;
		/**
		 * Internal tracker for the total change in value in the tween.
		 */
		protected var totalChange:Number;
		/**
		 * Internal tracker for the duration of the tween.
		 */
		protected var duration:Number;
		/**
		 * Internal tracker for the progress of the tween.
		 */
		protected var _progress:Number;
		
		
		/**
		 * Current progress of the tween, between 0 and `duration` inclusive.
		 */
		public function get progress():Number
		{
			return _progress;
		}
		
		/**
		* @private
		*/
		public function set progress(value:Number):void
		{
			if (value >= duration)
			{
				value = duration;
			}
			else if (value < 0)
			{
				value = 0;
			}
			
			_progress = value;
		}
		
		/**
		 * Returns `true` if the tween has finished to completion.
		 */
		public function get finished():Boolean
		{
			return (_progress >= duration);
		}
		
		/**
		 * The calculated value based on the current `progress`.
		 */
		public function get value():Number
		{
			return easingFunction(_progress, startValue, totalChange, duration);
		}
		
		/**
		 * A simple, linear tween (constant motion, with no acceleration).
		 *
		 * @param t	Specifies the current progress, between 0 and duration inclusive.
		 * @param b	Specifies the starting value.
		 * @param c	Specifies the total change in the value.
		 * @param d	Specifies the duration of the motion.
		 *
		 * @return	The value of the interpolated property at the specified time.
		 */
		public static function linear(t:Number, b:Number, c:Number, d:Number):Number
		{
			return b + (c*t)/d;
		}
	}
}
