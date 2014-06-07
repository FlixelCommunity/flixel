package flixel.system.debug
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flixel.FlxG;
	
	/**
	 * Container for the new debugger overlay.
	 * Most of the functionality is in the debug folder widgets,
	 * but this class instantiates the widgets and handles their basic formatting and arrangement.
	 */
	public class FlxDebugger 
	{
		/**
		 * Container for the performance monitor widget.
		 */
		public var perf:Perf;
		/**
		 * Container for the trace output widget.
		 */
		public var log:Log;
		/**
		 * Container for the watch window widget.
		 */
		public var watch:Watch;
		/**
		 * Container for the record, stop and play buttons.
		 * TODO: move this hack to FlxReplay, adding the proper signals.
		 */
		public static var vcr:VCR;
		/**
		 * Container for the visual debug mode toggle.
		 */
		public var vis:Vis;
		/**
		 * Whether the mouse is currently over one of the debugger windows or not.
		 */
		public var hasMouse:Boolean;
		
		/**
		 * Internal, tracks what debugger window layout user has currently selected.
		 */
		protected var _layout:uint;
		/**
		 * Internal, stores width and height of the Flash Player window.
		 */
		protected var _screen:Point;
		/**
		 * Internal, used to space out windows from the edges.
		 */
		protected var _gutter:uint;
		/**
		 * Internal, contains all overlays used by the debugger, e.g. console window.
		 */
		protected var _overlays:Sprite;
		
		/**
		 * Instantiates the debugger overlay.
		 * 
		 * @param Width		The width of the screen.
		 * @param Height	The height of the screen.
		 */
		public function FlxDebugger(Width:Number,Height:Number)
		{
			super();
			visible = false;
			hasMouse = false;
			_screen = new Point(Width,Height);
			_overlays = new Sprite();
			_overlays.visible = false;

			_overlays.addChild(new Bitmap(new BitmapData(Width, 15, true, 0x7f000000)));
			
			var txt:TextField = new TextField();
			txt.x = 2;
			txt.width = 160;
			txt.height = 16;
			txt.selectable = false;
			txt.multiline = false;
			txt.defaultTextFormat = new TextFormat("Courier",12,0xffffff);
			var str:String = FlxG.getLibraryName();
			if(FlxG.debug)
				str += " [debug]";
			else
				str += " [release]";
			txt.text = str;
			_overlays.addChild(txt);
			
			_gutter = 8;
			var screenBounds:Rectangle = new Rectangle(_gutter,15+_gutter/2,_screen.x-_gutter*2,_screen.y-_gutter*1.5-15);
			
			log = new Log("log",0,0,true,screenBounds);
			_overlays.addChild(log);
			
			watch = new Watch("watch",0,0,true,screenBounds);
			_overlays.addChild(watch);
			
			perf = new Perf("stats",0,0,false,screenBounds);
			_overlays.addChild(perf);
			
			vcr = new VCR();
			vcr.x = (Width - vcr.width/2)/2;
			vcr.y = 2;
			_overlays.addChild(vcr);
			
			vis = new Vis();
			vis.x = Width-vis.width - 4;
			vis.y = 2;
			_overlays.addChild(vis);
			
			setLayout(FlxG.DEBUGGER_STANDARD);
			
			//Should help with fake mouse focus type behavior
			_overlays.addEventListener(MouseEvent.MOUSE_OVER,handleMouseOver);
			_overlays.addEventListener(MouseEvent.MOUSE_OUT,handleMouseOut);
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			_screen = null;
			
			if (log != null)
			{
				_overlays.removeChild(log);
				log.destroy();
				log = null;
			}
			
			if (watch != null)
			{
				_overlays.removeChild(watch);
				watch.destroy();
				watch = null;
			}
			
			if (perf != null)
			{
				_overlays.removeChild(perf);
				perf.destroy();
				perf = null;
			}
			
			if (vcr != null)
			{
				_overlays.removeChild(vcr);
				vcr.destroy();
				vcr = null;
			}
			
			if (vis != null)
			{
				_overlays.removeChild(vis);
				vis.destroy();
				vis = null;
			}
			
			_overlays.removeEventListener(MouseEvent.MOUSE_OVER,handleMouseOver);
			_overlays.removeEventListener(MouseEvent.MOUSE_OUT,handleMouseOut);
		}
		
		/**
		 * Mouse handler that helps with fake "mouse focus" type behavior.
		 * 
		 * @param	E	Flash mouse event.
		 */
		protected function handleMouseOver(E:MouseEvent=null):void
		{
			hasMouse = true;
		}
		
		/**
		 * Mouse handler that helps with fake "mouse focus" type behavior.
		 * 
		 * @param	E	Flash mouse event.
		 */
		protected function handleMouseOut(E:MouseEvent=null):void
		{
			hasMouse = false;
		}
		
		/**
		 * Rearrange the debugger windows using one of the constants specified in FlxG.
		 * 
		 * @param	Layout		The layout style for the debugger windows, e.g. <code>FlxG.DEBUGGER_MICRO</code>.
		 */
		public function setLayout(Layout:uint):void
		{
			_layout = Layout;
			resetLayout();
		}
		
		/**
		 * Forces the debugger windows to reset to the last specified layout.
		 * The default layout is <code>FlxG.DEBUGGER_STANDARD</code>.
		 */
		public function resetLayout():void
		{
			switch(_layout)
			{
				case FlxG.DEBUGGER_MICRO:
					log.resize(_screen.x/4,68);
					log.reposition(0,_screen.y);
					watch.resize(_screen.x/4,68);
					watch.reposition(_screen.x,_screen.y);
					perf.reposition(_screen.x,0);
					break;
				case FlxG.DEBUGGER_BIG:
					log.resize((_screen.x-_gutter*3)/2,_screen.y/2);
					log.reposition(0,_screen.y);
					watch.resize((_screen.x-_gutter*3)/2,_screen.y/2);
					watch.reposition(_screen.x,_screen.y);
					perf.reposition(_screen.x,0);
					break;
				case FlxG.DEBUGGER_TOP:
					log.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					log.reposition(0,0);
					watch.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					watch.reposition(_screen.x,0);
					perf.reposition(_screen.x,_screen.y);
					break;
				case FlxG.DEBUGGER_LEFT:
					log.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
					log.reposition(0,0);
					watch.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
					watch.reposition(0,_screen.y);
					perf.reposition(_screen.x,0);
					break;
				case FlxG.DEBUGGER_RIGHT:
					log.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
					log.reposition(_screen.x,0);
					watch.resize(_screen.x/3,(_screen.y-15-_gutter*2.5)/2);
					watch.reposition(_screen.x,_screen.y);
					perf.reposition(0,0);
					break;
				case FlxG.DEBUGGER_STANDARD:
				default:
					log.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					log.reposition(0,_screen.y);
					watch.resize((_screen.x-_gutter*3)/2,_screen.y/4);
					watch.reposition(_screen.x,_screen.y);
					perf.reposition(_screen.x,0);
					break;
			}
		}
		
		public function get visible():Boolean
		{
			return _overlays != null && _overlays.visible;
		}
		
		public function set visible(Value:Boolean):void
		{
			if (_overlays != null)
			{
				_overlays.visible = Value;
			}
		}
		
		/**
		 * The area where all overlays are contained. Every windows used by the debugger, such as the console, is
		 * a child of this overlays area.
		 */
		public function get overlays():Sprite
		{
			return _overlays;
		}
	}
}
