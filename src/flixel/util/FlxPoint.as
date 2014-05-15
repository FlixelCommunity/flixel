package flixel.util
{
	import flash.geom.Point;
	
	/**
	 * Stores a 2D floating point coordinate.
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxPoint
	{
		
		/*     --- Static helper methods ---     */
		
		/**
		 * Calculates the angle between two points.  0 degrees points straight up.
		 * 
		 * @param	point1		The X coordinate of the point.
		 * @param	point2		The Y coordinate of the point.
		 * 
		 * @return	The angle in degrees, between -180 and 180.
		 */
		static public function angleBetween(point1:FlxPoint, point2:FlxPoint):Number
		{
			var x:Number = point2.x - point1.x;
			var y:Number = point2.y - point1.y;
			if((x == 0) && (y == 0))
				return 0;
			var c1:Number = 3.14159265 * 0.25;
			var c2:Number = 3 * c1;
			var ay:Number = (y < 0)?-y:y;
			var angle:Number = 0;
			if (x >= 0)
				angle = c1 - c1 * ((x - ay) / (x + ay));
			else
				angle = c2 - c1 * ((x + ay) / (ay - x));
			angle = ((y < 0)?-angle:angle)*57.2957796;
			if(angle > 90)
				angle = angle - 270;
			else
				angle += 90;
			return angle;
		}
		
		/**
		 * Calculate the distance between two points.
		 * 
		 * @param point1	A <code>FlxPoint</code> object referring to the first location.
		 * @param point2	A <code>FlxPoint</code> object referring to the second location.
		 * 
		 * @return	The distance between the two points as a floating point <code>Number</code> object.
		 */
		static public function distance(point1:FlxPoint, point2:FlxPoint):Number
		{
			var dx:Number = point1.x - point2.x;
			var dy:Number = point1.y - point2.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/**
		 * Rotates a point in 2D space around another point by the given angle.
		 * 
		 * @param	X		The X coordinate of the point you want to rotate.
		 * @param	Y		The Y coordinate of the point you want to rotate.
		 * @param	pivotX	The X coordinate of the point you want to rotate around.
		 * @param	pivotY	The Y coordinate of the point you want to rotate around.
		 * @param	angle	Rotate the point by this many degrees.
		 * @param	point	Optional <code>FlxPoint</code> to store the results in.
		 * 
		 * @return	A <code>FlxPoint</code> containing the coordinates of the rotated point.
		 */
		static public function rotate(X:Number, Y:Number, pivotX:Number, pivotY:Number, angle:Number, point:FlxPoint=null):FlxPoint
		{
			var sin:Number = 0;
			var cos:Number = 0;
			var radians:Number = angle * -0.017453293;
			while (radians < -3.14159265)
				radians += 6.28318531;
			while (radians >  3.14159265)
				radians = radians - 6.28318531;
			
			if (radians < 0)
			{
				sin = 1.27323954 * radians + .405284735 * radians * radians;
				if (sin < 0)
					sin = .225 * (sin *-sin - sin) + sin;
				else
					sin = .225 * (sin * sin - sin) + sin;
			}
			else
			{
				sin = 1.27323954 * radians - 0.405284735 * radians * radians;
				if (sin < 0)
					sin = .225 * (sin *-sin - sin) + sin;
				else
					sin = .225 * (sin * sin - sin) + sin;
			}
			
			radians += 1.57079632;
			if (radians >  3.14159265)
				radians = radians - 6.28318531;
			if (radians < 0)
			{
				cos = 1.27323954 * radians + 0.405284735 * radians * radians;
				if (cos < 0)
					cos = .225 * (cos *-cos - cos) + cos;
				else
					cos = .225 * (cos * cos - cos) + cos;
			}
			else
			{
				cos = 1.27323954 * radians - 0.405284735 * radians * radians;
				if (cos < 0)
					cos = .225 * (cos *-cos - cos) + cos;
				else
					cos = .225 * (cos * cos - cos) + cos;
			}
			
			var dx:Number = X-pivotX;
			var dy:Number = pivotY+Y; //Y axis is inverted in flash, normally this would be a subtract operation
			if(point == null)
				point = new FlxPoint();
			point.x = pivotX + cos*dx - sin*dy;
			point.y = pivotY - sin*dx - cos*dy;
			return point;
		}
		
		
		/*     --- Actual instance ---     */
		
		/**
		 * @default 0
		 */
		public var x:Number;
		/**
		 * @default 0
		 */
		public var y:Number;
		
		/**
		 * Instantiate a new point object.
		 * 
		 * @param	X		The X-coordinate of the point in space.
		 * @param	Y		The Y-coordinate of the point in space.
		 */
		public function FlxPoint(X:Number=0, Y:Number=0)
		{
			x = X;
			y = Y;
		}
		
		/**
		 * Instantiate a new point object.
		 * 
		 * @param	X		The X-coordinate of the point in space.
		 * @param	Y		The Y-coordinate of the point in space.
		 */
		public function make(X:Number=0, Y:Number=0):FlxPoint
		{
			x = X;
			y = Y;
			return this;
		}
		
		/**
		 * Helper function, just copies the values from the specified point.
		 * 
		 * @param	point	Any <code>FlxPoint</code>.
		 * 
		 * @return	A reference to itself.
		 */
		public function copyFrom(point:FlxPoint):FlxPoint
		{
			x = point.x;
			y = point.y;
			return this;
		}
		
		/**
		 * Helper function, just copies the values from this point to the specified point.
		 * 
		 * @param	point	Any <code>FlxPoint</code>.
		 * 
		 * @return	A reference to the altered point parameter.
		 */
		public function copyTo(point:FlxPoint):FlxPoint
		{
			point.x = x;
			point.y = y;
			return point;
		}
		
		/**
		 * Helper function, just copies the values from the specified Flash point.
		 * 
		 * @param	Point	Any <code>Point</code>.
		 * 
		 * @return	A reference to itself.
		 */
		public function copyFromFlash(FlashPoint:Point):FlxPoint
		{
			x = FlashPoint.x;
			y = FlashPoint.y;
			return this;
		}
		
		/**
		 * Helper function, just copies the values from this point to the specified Flash point.
		 * 
		 * @param	Point	Any <code>Point</code>.
		 * 
		 * @return	A reference to the altered point parameter.
		 */
		public function copyToFlash(FlashPoint:Point):Point
		{
			FlashPoint.x = x;
			FlashPoint.y = y;
			return FlashPoint;
		}
	}
}
