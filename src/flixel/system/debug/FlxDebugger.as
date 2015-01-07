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
	import flash.ui.Mouse;
	
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
		 * Internal, tells if the debugger was already initialized.
		 */
		protected var _initialized:Boolean;
		/**
		 * Internal, tells if the default system mouse cursor should be used instead of custom Flixel mouse cursors.
		 */
		protected var _useSystemCursor:Boolean;
		
		/**
		 * Instantiates the debugger overlay.
		 * 
		 * @param OverlaysContainer	The container where the debugger can add its overlays.
		 * @param Width				The width of the screen.
		 * @param Height			The height of the screen.
		 * @param UseSystemCursor 	Tells if the default system mouse cursor should be used instead of custom Flixel mouse cursors.
		 * @param Initialize 		If <code>true</code> (default), the debugger will initialize its interal structures and will be ready to work, otherwise it remain in a "stand-by" mode and will only initialize if <code>show()</code> is invoked.
		 */
		public function FlxDebugger(OverlaysContainer:Sprite,Width:Number,Height:Number,UseSystemCursor:Boolean,Initialize:Boolean = true)
		{
			super();
			hasMouse = false;
			_screen = new Point(Width,Height);
			_initialized = false;
			_useSystemCursor = UseSystemCursor;
			_overlays = new Sprite();
			_overlays.visible = false;
			
			OverlaysContainer.addChild(_overlays);
			
			if (Initialize)
			{
				init();
			}
		}
		
		/**
		 * Initializes the debugger, creating all overlays.
		 */
		protected function init():void
		{
			_initialized = true;
			
			_overlays.addChild(new Bitmap(new BitmapData(_screen.x, 15, true, 0x7f000000)));
			
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
			
			vis = new Vis();
			vis.x = _screen.x-vis.width - 4;
			vis.y = 2;
			_overlays.addChild(vis);
			
			setLayout(FlxG.DEBUGGER_STANDARD);
			
			//Should help with fake mouse focus type behavior
			_overlays.addEventListener(MouseEvent.MOUSE_OVER,handleMouseOver);
			_overlays.addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
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
		 * Show/hide the Flash cursor according to the debugger's visilibity.
		 */
		protected function adjustFlashCursorVisibility():void
		{
			if(visible)
				flash.ui.Mouse.show();
			else if(!_useSystemCursor)
				flash.ui.Mouse.hide();
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
		
		/**
		 * Read-only property that tells is the debugger is visible or not. You can
		 * use the methods <code>show()</code> and <code>hide()</code> to control the
		 * debugger visility.
		 */
		public function get visible():Boolean
		{
			return _overlays != null && _overlays.visible;
		}
		
		/**
		 * Hide the debugger. This method essentially sets the <code>visible</code> property to <code>false</code>.
		 */
		public function hide():void
		{
			_overlays.visible = false;
			adjustFlashCursorVisibility();
		}
		
		/**
		 * Toggles the debugger visility. This method obeys <code>FlxG.debug</code>, which means that
		 * if <code>FlxG.debug</code> is <code>false</code>, the method will silenty fail
		 * and will not toggle the debugger visibility. It's possible to ignore <code>FlxG.debug</code>
		 * by using the <code>Force</code> parameter.
		 * 
		 * @param	Force if <code>true</code> the method will ignore <code>FlxG.debug</code> and will toggle the debugger visibility. If <code>false</code>(default) the method will only toggle the debugger visibility if <code>FlxG.debug</code> is <code>true</code>.
		 */
		public function toggleVisility(Force:Boolean = false):void
		{
			if (Force || FlxG.debug) {
				if (visible)
					hide();
				else
					show();
			}
		}
		
		/**
		 * Shows the debugger. This method obeys <code>FlxG.debug</code>, which means that
		 * if <code>FlxG.debug</code> is <code>false</code>, the method will silenty fail
		 * and will not display the debugger. It's possible to ignore <code>FlxG.debug</code>
		 * by using the <code>Force</code> parameter.
		 * 
		 * @param	Force if <code>true</code> the method will ignore <code>FlxG.debug</code> and will show the debugger. If <code>false</code>(default) the method will only show the debugger if <code>FlxG.debug</code> is <code>true</code>.
		 */
		public function show(Force:Boolean = false):void
		{
			if (Force || FlxG.debug) {
				if (!_initialized)
				{
					// Debugger was only added to the screen, but not initialized.
					init();
				}
				_overlays.visible = true;
				adjustFlashCursorVisibility();
			}
		}
		
		/**
		 * Adds an overlay to the debugger. Every windows used by the debugger, such as the console, is
		 * an overlay. The overlay is added at the very top of the list, so it will appear in front
		 * of all previously added overlays. Use <code>addOverlayAt()</code> to add an overlay
		 * to a specific position.
 		 * 
		 * @param	Overlay		The overlay to be added to the debugger.
		 */
		public function addOverlay(Overlay:Sprite):void
		{
			_overlays.addChild(Overlay);
		}
		
		/**
		 * Adds an overlay to the debugger at an specific position (layer) on the screen.
		 * If you specify a currently occupied index position, the overlay object that exists at that
		 * position and all higher positions are moved up one position in the overlays list.
 		 * 
		 * @param	Overlay		The overlay to be added to the debugger.
		 * @param	Index		The index to which the overlay is added. 
		 */
		public function addOverlayAt(Overlay:Sprite, Index:int):void
		{
			_overlays.addChildAt(Overlay, Index);
		}
		
		/**
		 * Removes an overlay from the debugger.
		 * 
		 * @param	Overlay		The overlay to be removed.
		 */
		public function removeOverlay(Overlay:Sprite):void
		{
			if (Overlay != null)
			{
				_overlays.removeChild(Overlay);
			}
		}
		
		/**
		 * Removes an overlay by its index in the screen. 
		 * 
		 * @param	Index		The index from which the overlay is removed.
		 */
		public function removeOverlayAt(Index:int):void
		{
			_overlays.removeChildAt(Index);
		}
		
		/**
		 * Tells if the debugger is initialized. When Flixel starts, it will create a bare minimum
		 * and uninitialized debugger if <code>FlxG.debug</code> is <code>false</code>. The debugger
		 * will automatically initialize itself if a call to <code>show()</code> is made.
		 */
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		/**
		 * The width of the visual debugger area, which is the Flash Player window width.
		 */
		public function get width():Number
		{
			return _screen.x;
		}
		
		/**
		 * The height of the visual debugger area, which is the Flash Player window height.
		 */
		public function get height():Number
		{
			return _screen.y;
		}
	}
}
