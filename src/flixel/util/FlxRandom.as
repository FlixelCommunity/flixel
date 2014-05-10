package flixel.util
{
	import flixel.FlxG;
	
	/**
	 * A class containing a set of functions for random generation.
	 * 
	 * There are no static methods for retrieving random numbers; either create your own instance of the FlxRandom class, or use the 'FlxG.random' instance.
	 */
	public class FlxRandom
	{
		/**
		 * Creates a new instance of the FlxRandom class.
		 * 
		 * If you want, you can set the seed with an integer between  inclusive. However, FlxG automatically sets this with a new random seed when starting your game.
		 *
		 * @param	seed	The seed you wish to use to start off the random number generator; needs to be a value between MIN_SEED (1) and MAX_SEED (2,147,483,646). If the value is set to 0, a random starting seed will be chosen.
		 */
		public function FlxRandom(seed:uint = 0)
		{
			if (seed == 0) 
			{
				this.randomizeSeed();
			}
			else
			{
				this.seed = seed;
			}
		}
		
		/** 
		 * The smallest allowed value for a seed, based on the current algorithm used for the pseudo-random number generation.
		 */
		public static const MIN_SEED:uint = 1;
		public static const MAX_SEED:uint = 0x7FFFFFFF - 1; // Results in 0x7FFFFFFE, but the -1 makes it a bit clearer I feel.
		
		// The original seed that was set by the user
		protected var _seed:int = 0;
		
		// Internal tracker that keeps track of the current value of the seed as it changes with each iteration
		protected var _currentSeed:int = 0;
		
		/**
		 * The original seed value used to start off the pseudo-random number generator. When set, will also reset the value of 'currentSeed'.
		 */
		public function get seed():uint
		{
			return _seed;
		}
		
		/**
		 * @private
		 */
		public function set seed(value:uint):void
		{
			if ( (value < MIN_SEED) || (value > MAX_SEED) )
			{
				FlxG.log("ERROR: Invalid seed value of '" + value + "' passed to 'flixel.util.FlxRandom'. The value must be between '" + MIN_SEED + "' and '" + MAX_SEED + "'.");
				FlxG.log("To prevent problems with the random number generator, the seed will instead be set to '1'.");
				value = 1;
			}
			
			_seed = value;
			_currentSeed = value;
		}
		
		/**
		 * The current "state" of the original seed. This value changes each time the 'generate()' method is called.
		 */
		public function get currentSeed():uint 
		{
			return _currentSeed;
		}
		
		/**
		 * Resets the current "state" of the seed (represented by the 'currentSeed' value) to the original 'seed' value.
		 */
		public function resetSeed():void
		{
			_currentSeed = seed;
		}
		
		/**
		 * Picks a new random seed. Note that the seed is chosen by AS3's time-based random generator, and (obviously) not a seeded pseudo-random number generator.
		 */
		public function randomizeSeed():void
		{
			var newSeed:uint = 0;
			while (newSeed == 0)
			{
				// Odds are 1:2^31, but this might return 0!!
				newSeed = uint(Math.random() * MODULUS);
			}
			this.seed = newSeed;
		}
		
		
		/**
		 * Constants used in the pseudorandom number generation equation.
		 * These are the constants suggested by the revised MINSTD pseudorandom number generator, and they use the full range of possible integer values.
		 * 
		 * @see 	http://en.wikipedia.org/wiki/Linear_congruential_generator
		 * @see 	Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988). "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
		 */
		protected const MULTIPLIER:int = 48271;
		protected const MODULUS:int = 2147483647; // 0x7FFFFFFF (31 bit integer)
		
		/**
		 * Internal method to quickly generate a pseudorandom number. Used only by other functions of this class.
		 * Also updates the current seed, which will then be used to generate the next pseudorandom number.
		 * 
		 * @return	A new pseudorandom number between 0 inclusive and 1 exclusive.
		 */
		protected function generate():Number
		{
			_currentSeed = ((_currentSeed * MULTIPLIER) % MODULUS);
			return (_currentSeed / MODULUS);
		}
		
		
	}
}
