package flixel.util
{
	import flixel.FlxG;
	import flixel.util.FlxU;
	
	/**
	 * A class containing a set of functions for random generation.
	 * 
	 * @see 	http://en.wikipedia.org/wiki/Linear_congruential_generator
	 * @see 	Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988). "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
	 * 
	 * Contains modified code from the following libraries:
	 *  - HaxeFlixel (released under the MIT License) <https://github.com/HaxeFlixel/flixel>
	 *  - AS3Libs by Grant Skinner (released under the MIT License) <https://github.com/gskinner/AS3Libs>
	 * 
	 * There are no static methods for retrieving random numbers; either create your own instance of the FlxRandom class, or use the <code>FlxG.random</code> instance.
	 */
	public class FlxRandom
	{
		/**
		 * Creates a new instance of the <code>FlxRandom</code> class.
		 * 
		 * If you want, you can set the seed with an integer between  inclusive. However, <code>FlxG</code> automatically sets this with a new random seed when starting your game.
		 *
		 * @param	seed	The seed you wish to use to start off the random number generator; needs to be a value between <code>MIN_SEED</code> (<code>1</code>) and <code>MAX_SEED</code> (<code>2,147,483,646</code>). If the value is set to <code>0</code>, a random starting seed will be chosen.
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
		 * The original seed value used to start off the pseudo-random number generator. When set, will also reset the value of <code>currentSeed</code>.
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
		 * The current "state" of the original seed. This value changes each time the <code>generate()</code> method is called.
		 */
		public function get currentSeed():uint 
		{
			return _currentSeed;
		}
		
		/**
		 * Resets the current "state" of the seed (represented by the <code>currentSeed</code> value) to the original <code>seed</code> value.
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
		 * These are the constants suggested by the revised "minimum standard" pseudo-random number generator, and result in an integer between <code>1</code> and <code>0x7FFFFFFF-1</code> (see <code>MIN_SEED</code> and <code>MAX_SEED</code> values)
		 */
		protected const MULTIPLIER:int = 48271;
		protected const MODULUS:int = 2147483647; // 0x7FFFFFFF (31 bit integer)
		
		/**
		 * Internal method to quickly generate a pseudorandom number. Used only by other functions of this class.
		 * Also updates the current seed, which will then be used to generate the next pseudorandom number.
		 * 
		 * @return	A new pseudorandom number between <code>0</code> inclusive and <code>1</code> exclusive.
		 */
		protected function generate():Number
		{
			_currentSeed = ((_currentSeed * MULTIPLIER) % MODULUS);
			return (_currentSeed / MODULUS);
		}
		
		/**
		 * Returns a pseudo-random float (also known as <code>Number</code> in ActionScript 3) value between <code>min</code> inclusive and <code>max</code> exclusive.
		 * That is <code>[min, max)</code>
		 * 
		 * @param	min			The minimum value that should be returned. <code>0</code> by default.
		 * @param	max			The maximum value that should be returned. <code>1</code> by default.
		 */
		public function float(min:Number = 0, max:Number = 1):Number
		{
			if ( (min == 0) && (max == 1) ) { return generate(); } // For performance 
			else return min + generate() * (max - min);
		}
		
		/**
		 * Returns either a <code>true</code> or <code>false</code> based on the chance value.
		 * A chance value of 0.5 means a 50% chance of <code>true</code> being returned.
		 * A chance value of 0.8 means an 80% chance of <code>true</code> being returned.
		 * A chance value of 0 means <code>false</code> will always be returned.
		 * 
		 * @param	chance		The odds of returning <code>true</code>. 0.5 (50% chance) by default.
		 */
		public function boolean(chance:Number = 0.5):Boolean
		{
			return (generate() < chance);
		}
		
		/**
		 * Returns either a <code>1</code> or <code>-1</code> based on the chance value.
		 * A chance value of <code>0.8</code> means an 80% chance of <code>1</code> being returned.
		 * A chance value of <code>0</code> means <code>false</code> will always be returned.
		 * 
		 * Recommended to be used with the <code>*</code> operator: <code>score += random.sign(0.8) * 10;</code> will result in an 80% chance of <code>10</code> and a 20% chance of <code>-10</code>.
		 * 
		 * @param	chance		The odds of returning <code>1</code>. <code>0.5</code> (50% chance) by default.
		 */
		public function sign(chance:Number = 0.5):int
		{
			return (generate() < chance) ? 1 : -1;
		}
		
		/**
		 * Returns either a <code>1</code> or <code>0</code> based on the chance value.
		 * A chance value of 0.5 means a 50% chance of <code>1</code> being returned.
		 * A chance value of 0.8 means an 80% chance of <code>1</code> being returned.
		 * A chance value of 0 means <code>0</code> will always be returned.
		 * 
		 * @param	chance		The odds of returning <code>1</code>. <code>0.5</code> (50% chance) by default.
		 */
		public function bit(chance:Number=0.5):int 
		{
			return (generate() < chance) ? 1 : 0;
		}
		
		/**
		 * Returns a pseudo-random integer between the specified range <code>min</code> and <code>max</code>, both inclusive.
		 * That is <code>[min, max]</code>.
		 * 
		 * If no <code>max</code> value is specified, a value between <code>0</code> and the first argument will be returned instead.
		 * 
		 * @param	min			The minimum value that should be returned. Required.
		 * @param	max			The maximum value that should be returned. If omitted, the first parameter will instead be treated as the <code>max</code> value.
		 */
		public function integer(min:Number, max:Number = NaN):int
		{
			if (isNaN(max)) { max = min; min = 0; }
			// Need to use floor instead of bit shift to work properly with negative values:
			return FlxU.floor(float(min, max + 1));
		}
		
		/**
		 * Select a random item from the specified array. Does not modify the array.
		 * Will return <code>null</code> if random selection is missing, or array has no entries.
		 * 
		 * @param	array			The array to pick the item from.
		 * @param	startIndex		Optional offset off the front of the array. Default value is 0, or the beginning of the array.
		 * @param	length			Optional restriction on the number of values you want to randomly select from.
		 */
		public function item(array:Array, startIndex:uint = 0, length:uint = 0):*
		{
			if ((length == 0) || (length > (array.length - startIndex)))
				{ length = (array.length - startIndex); }
			
			if (length > 0)
				{ return array[startIndex + uint(length * generate())]; }
			
			return null;
		}
		
		/**
		 * Shuffles the entire array into a new pseudo-random order.
		 * 
		 * @param	array			An array to shuffle.
		 * @param	modifyArray		Whether or not to modify the passed in array. If set to <code>false</code>, a new array with the same values will be returned instead of modifying the original one.
		 * @return	The newly shuffled array.
		 */
		public function shuffle(array:Array, modifyArray:Boolean = true):Array
		{
			if (!modifyArray)
				{ array = array.slice(); }
			
			var len:int = array.length;
			for (var i:uint = 0; i < len; i++)
			{
				var j:uint = uint(len * generate());
				if (j == i) { continue; }
				
				var item:* = array[j];
				array[j] = array[i];
				array[i] = item;
			}
			return array;
		}
		
		/**
		 * Chooses a random color, or greyscale shade.
		 * 
		 * NOTE: For non-32 bit colors, you may want to set the <code>alpha</code> to <code>0</code> to return the color as <code>0xRRGGBB</code>, though, the alpha bits are usually ignored in practice if they aren't used by a certain function.
		 * 
		 * @param	alpha			The alpha value, from <code>0 (transparent) to <code>1 (opaque)
		 * @param	greyScale		Whether or not to return a shade of grey instead of a color. Defaults to <code>false</code>.
		 * @return	The 32 bit color in the format 0xAARRGGBB
		 */
		public function color(alpha:Number = 1, greyScale:Boolean = false):uint
		{
			if (alpha > 1) { alpha = 1; }
			if (alpha < 0) { alpha = 0; }
			var alphaHex:uint = uint(0xFF * alpha);
			
			// Since `generate()` can never return `1`, we will never get exactly pure white (0xFFFFFF). Oh well, we can come close.
			if (greyScale)
			{
				var greyHex:uint = uint(0xFF * generate());
				return alphaHex << 24 | greyHex << 16 | greyHex << 8 | greyHex << 0;
			}
			else
			{
				return alphaHex << 24 | uint(0xFFFFFF * generate());
			}
		}
		
	}
}
