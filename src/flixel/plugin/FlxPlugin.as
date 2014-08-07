package flixel.plugin
{
	import flixel.FlxG;

	/**
	 * Defines the structure of all plugins.
	 * 
	 * @author	Fernando Bevilacqua (Dovyski)
	 */
	public interface FlxPlugin
	{
		/**
		 * Destroys the plugin.
		 */
		function destroy():void;
	}
}