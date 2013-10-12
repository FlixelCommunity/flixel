package org.flixel.system.input
{
	public class KeyState
	{
		public var name:String;
		public var current:int;
		public var last:int;

		public function KeyState(Name:String, Current:int, Last:int)
		{
			name = Name;
			current = Current;
			last = Last;
		}
	}
}
