package flixel.util
{
	/**
	 * Contains various Math functions and helpers, not dependent on any target platform.
	 */
	public class FlxMath
	{
		/**
		 * Calculate the absolute value of a number.
		 * 
		 * @param	Value	Any number.
		 * 
		 * @return	The absolute value of that number.
		 */
		static public function abs(Value:Number):Number
		{
			return (Value>0)?Value:-Value;
		}
		
		/**
		 * Round down to the next whole number. E.g. floor(1.7) == 1, and floor(-2.7) == -2.
		 * 
		 * @param	Value	Any number.
		 * 
		 * @return	The rounded value of that number.
		 */
		static public function floor(Value:Number):Number
		{
			var number:Number = int(Value);
			return (Value>0)?(number):((number!=Value)?(number-1):(number));
		}
		
		/**
		 * Round up to the next whole number.  E.g. ceil(1.3) == 2, and ceil(-2.3) == -3.
		 * 
		 * @param	Value	Any number.
		 * 
		 * @return	The rounded value of that number.
		 */
		static public function ceil(Value:Number):Number
		{
			var number:Number = int(Value);
			return (Value>0)?((number!=Value)?(number+1):(number)):(number);
		}
		
		/**
		 * Round to the closest whole number. E.g. round(1.7) == 2, and round(-2.3) == -2.
		 * 
		 * @param	Value	Any number.
		 * 
		 * @return	The rounded value of that number.
		 */
		static public function round(Value:Number):Number
		{
			return int(Value+((Value>0)?0.5:-0.5));
		}
		
		/**
		 * Figure out which number is smaller.
		 * 
		 * @param	Number1		Any number.
		 * @param	Number2		Any number.
		 * 
		 * @return	The smaller of the two numbers.
		 */
		static public function min(Number1:Number,Number2:Number):Number
		{
			return (Number1 <= Number2)?Number1:Number2;
		}
		
		/**
		 * Figure out which number is larger.
		 * 
		 * @param	Number1		Any number.
		 * @param	Number2		Any number.
		 * 
		 * @return	The larger of the two numbers.
		 */
		static public function max(Number1:Number,Number2:Number):Number
		{
			return (Number1 >= Number2)?Number1:Number2;
		}
		
		/**
		 * Clamp (bound) a number by a minimum and maximum.
		 * Ensures that this number is no smaller than the minimum,
		 * and no larger than the maximum.
		 * 
		 * @param	Value	Any number.
		 * @param	Min		Any number.
		 * @param	Max		Any number.
		 * 
		 * @return	The clamped (bounded) value of the number.
		 */
		static public function clamp(Value:Number,Min:Number,Max:Number):Number
		{
			var lowerBound:Number = (Value<Min)?Min:Value;
			return (lowerBound>Max)?Max:lowerBound;
		}
		
		
		/**
		 * A tween-like function that takes a starting velocity
		 * and some other factors and returns an altered velocity.
		 * 
		 * @param	TimeElapsed		The amount of time in seconds that passed since last frame.
		 * @param	Velocity		Any component of velocity (e.g. 20).
		 * @param	Acceleration	Rate at which the velocity is changing.
		 * @param	Drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
		 * @param	Max				An optional absolute value cap for the velocity.
		 * 
		 * @return	The altered Velocity value.
		 */
		static public function computeVelocity(TimeElapsed:Number, Velocity:Number, Acceleration:Number=0, Drag:Number=0, Max:Number=NaN):Number
		{
			if(Acceleration != 0)
				Velocity += Acceleration*TimeElapsed;
			else if(Drag != 0)
			{
				var drag:Number = Drag*TimeElapsed;
				if(Velocity - drag > 0)
					Velocity = Velocity - drag;
				else if(Velocity + drag < 0)
					Velocity += drag;
				else
					Velocity = 0;
			}
			if((Velocity != 0) && (!isNaN(Max)))
			{
				Velocity = FlxMath.clamp(Velocity, -Max, Max);
			}
			return Velocity;
		}
	}
}
