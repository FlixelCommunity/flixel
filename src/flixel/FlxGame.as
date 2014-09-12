package flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	
	import flixel.plugin.replay.FlxReplay;
	import flixel.util.FlxMath;
	import flixel.system.FlxSave;
	import flixel.system.debug.FlxDebugger;
	
	import flixel.system.render.FlxRender;
	import flixel.system.render.blitting.FlxBlittingRender;
	import flixel.system.render.genome2d.FlxGenome2DRender;

	/**
	 * FlxGame is the heart of all flixel games, and contains a bunch of basic game loops and things.
	 * It is a long and sloppy file that you shouldn't have to worry about too much!
	 * It is basically only used to create your game object in the first place,
	 * after that FlxG and FlxState have all the useful stuff you actually need.
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxGame extends Sprite
	{
		[Embed(source="assets/nokiafc22.ttf",fontFamily="system",embedAsCFF="false")] protected var junk:String;
		[Embed(source="assets/beep.mp3")] protected var SndBeep:Class;
		[Embed(source="assets/logo.png")] protected var ImgLogo:Class;

		/**
		 * Sets 0, -, and + to control the global volume sound volume.
		 * @default true
		 */
		public var useSoundHotKeys:Boolean;
		/**
		 * Tells flixel to use the default system mouse cursor instead of custom Flixel mouse cursors.
		 * @default false
		 */
		public var useSystemCursor:Boolean;
		/**
		 * Initialize and allow the flixel debugger overlay even in release mode.
		 * Also useful if you don't use FlxPreloader!
		 * @default false
		 */
		public var forceDebugger:Boolean;

		/**
		 * The render flixel is using to draw things into the screen.
		 * All available renders are in the <code>system.render</code> package.
		 */
		internal var _render:FlxRender;
		/**
		 * Tells flixel to use hardware acceleration (Stage3D) to draw things.
		 */
		internal var _useGPU:Boolean;
		/**
		 * Current game state.
		 */
		internal var _state:FlxState;
		/**
		 * Mouse cursor.
		 */
		internal var _mouse:Sprite;
		
		/**
		 * Class type of the initial/first game state for the game, usually MenuState or something like that.
		 */
		protected var _iState:Class;
		/**
		 * Whether the game object's basic initialization has finished yet.
		 */
		protected var _created:Boolean;
		
		/**
		 * Total number of milliseconds elapsed since game start.
		 */
		protected var _total:uint;
		/**
		 * Total number of milliseconds elapsed since last update loop.
		 * Counts down as we step through the game loop.
		 */
		protected var _accumulator:int;
		/**
		 * Whether the Flash player lost focus.
		 */
		protected var _lostFocus:Boolean;
		/**
		 * Milliseconds of time per step of the game loop.  FlashEvent.g. 60 fps = 16ms.
		 */
		internal var _step:uint;
		/**
		 * Framerate of the Flash player (NOT the game loop). Default = 30.
		 */
		internal var _flashFramerate:uint;
		/**
		 * Max allowable accumulation (see _accumulator).
		 * Should always (and automatically) be set to roughly 2x the flash player framerate.
		 */
		internal var _maxAccumulation:uint;
		/**
		 * If a state change was requested, the new state object is stored here until we switch to it.
		 */
		internal var _requestedState:FlxState;
		/**
		 * A flag for keeping track of whether a game reset was requested or not.
		 */
		internal var _requestedReset:Boolean;

		/**
		 * The "focus lost" screen (see <code>createFocusScreen()</code>).
		 */
		protected var _focus:Sprite;
		/**
		 * The sound tray display container (see <code>createSoundTray()</code>).
		 */
		protected var _soundTray:Sprite;
		/**
		 * Helps us auto-hide the sound tray after a volume change.
		 */
		protected var _soundTrayTimer:Number;
		/**
		 * Helps display the volume bars on the sound tray.
		 */
		protected var _soundTrayBars:Array;
		/**
		 * The debugger overlay object.
		 */
		internal var _debugger:FlxDebugger;
		/**
		 * A handy boolean that keeps track of whether the debugger exists and is currently visible.
		 */
		internal var _debuggerUp:Boolean;
		
		/**
		 * Instantiate a new game object.
		 * 
		 * @param	GameSizeX		The width of your game in game pixels, not necessarily final display pixels (see Zoom).
		 * @param	GameSizeY		The height of your game in game pixels, not necessarily final display pixels (see Zoom).
		 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).
		 * @param	Zoom			The default level of zoom for the game's cameras (e.g. 2 = all pixels are now drawn at 2x).  Default = 1.
		 * @param	GameFramerate	How frequently the game should update (default is 60 times per second).
		 * @param	FlashFramerate	Sets the actual display framerate for Flash player (default is 30 times per second).
		 * @param	UseSystemCursor	Whether to use the default OS mouse pointer, or to use custom flixel ones.
		 * @param	UseGPU			Whether to use hardware acceleration for rendering (with Genome2D). Default is <code>false</code> (meaning that flixel will use blitting/CPU to draw things).
		 */
		public function FlxGame(GameSizeX:uint,GameSizeY:uint,InitialState:Class,Zoom:Number=1,GameFramerate:uint=60,FlashFramerate:uint=30,UseSystemCursor:Boolean=false,UseGPU:Boolean=false)
		{
			//super high priority init stuff (focus, mouse, etc)
			_lostFocus = false;
			_focus = new Sprite();
			_focus.visible = false;
			_soundTray = new Sprite();
			_mouse = new Sprite();
			
			//basic display and update setup stuff
			FlxG.init(this,GameSizeX,GameSizeY,Zoom);
			FlxG.framerate = GameFramerate;
			FlxG.flashFramerate = FlashFramerate;
			_accumulator = _step;
			_total = 0;
			_state = null;
			useSoundHotKeys = true;
			useSystemCursor = UseSystemCursor;
			if(!useSystemCursor)
				flash.ui.Mouse.hide();
			forceDebugger = false;
			_debuggerUp = false;
			
			//then get ready to create the game object for real
			_iState = InitialState;
			_requestedState = null;
			_requestedReset = true;
			_created = false;
			
			// inform the subsequent init code to use GPU for rendering.
			_useGPU = UseGPU;
			
			addEventListener(Event.ADDED_TO_STAGE, create);
		}
		
		/**
		 * Makes the little volume tray slide out.
		 * 
		 * @param	Silent	Whether or not it should beep.
		 */
		internal function showSoundTray(Silent:Boolean=false):void
		{
			if(!Silent)
				FlxG.play(SndBeep);
			_soundTrayTimer = 1;
			_soundTray.y = 0;
			_soundTray.visible = true;
			var globalVolume:uint = Math.round(FlxG.volume*10);
			if(FlxG.mute)
				globalVolume = 0;
			for (var i:uint = 0; i < _soundTrayBars.length; i++)
			{
				if(i < globalVolume) _soundTrayBars[i].alpha = 1;
				else _soundTrayBars[i].alpha = 0.5;
			}
		}

		/**
		 * Internal event handler for input and focus.
		 * 
		 * @param	FlashEvent	Flash keyboard event.
		 */
		protected function handleKeyUp(FlashEvent:KeyboardEvent):void
		{
			if(_debuggerUp && _debugger.watch.editing)
				return;
			if(!FlxG.mobile)
			{
				if((_debugger != null) && ((FlashEvent.keyCode == 192) || (FlashEvent.keyCode == 220)))
				{
					_debugger.visible = !_debugger.visible;
					_debuggerUp = _debugger.visible;
					if(_debugger.visible)
						flash.ui.Mouse.show();
					else if(!useSystemCursor)
						flash.ui.Mouse.hide();
					//_console.toggle();
					return;
				}
				if(useSoundHotKeys)
				{
					var c:int = FlashEvent.keyCode;
					//var code:String = String.fromCharCode(FlashEvent.charCode);
					switch(c)
					{
						case 48:
						case 96:
							FlxG.mute = !FlxG.mute;
							if(FlxG.volumeHandler != null)
								FlxG.volumeHandler(FlxG.mute?0:FlxG.volume);
							showSoundTray();
							return;
						case 109:
						case 189:
							FlxG.mute = false;
				    		FlxG.volume = FlxG.volume - 0.1;
				    		showSoundTray();
							return;
						case 107:
						case 187:
							FlxG.mute = false;
				    		FlxG.volume = FlxG.volume + 0.1;
				    		showSoundTray();
							return;
						default:
							break;
					}
				}
			}
			
			FlxG.keys.handleKeyUp(FlashEvent);
		}
		
		/**
		 * Internal event handler for input and focus.
		 * 
		 * @param	FlashEvent	Flash keyboard event.
		 */
		protected function handleKeyDown(FlashEvent:KeyboardEvent):void
		{
			if(_debuggerUp && _debugger.watch.editing)
				return;

			FlxG.keys.handleKeyDown(FlashEvent);
		}
		
		/**
		 * Internal event handler for input and focus.
		 * 
		 * @param	FlashEvent	Flash mouse event.
		 */
		protected function handleMouseDown(FlashEvent:MouseEvent):void
		{
			if(_debuggerUp)
			{
				if(_debugger.hasMouse)
					return;
				if(_debugger.watch.editing)
					_debugger.watch.submit();
			}
			
			FlxG.mouse.handleMouseDown(FlashEvent);
		}
		
		/**
		 * Internal event handler for input and focus.
		 * 
		 * @param	FlashEvent	Flash mouse event.
		 */
		protected function handleMouseUp(FlashEvent:MouseEvent):void
		{
			if(_debuggerUp && _debugger.hasMouse)
				return;
			FlxG.mouse.handleMouseUp(FlashEvent);
		}
		
		/**
		 * Internal event handler for input and focus.
		 * 
		 * @param	FlashEvent	Flash mouse event.
		 */
		protected function handleMouseWheel(FlashEvent:MouseEvent):void
		{
			if(_debuggerUp && _debugger.hasMouse)
				return;
			FlxG.mouse.handleMouseWheel(FlashEvent);
		}
		
		/**
		 * Internal event handler for input and focus.
		 * 
		 * @param	FlashEvent	Flash event.
		 */
		protected function onFocus(FlashEvent:Event=null):void
		{
			if(!_debuggerUp && !useSystemCursor)
				flash.ui.Mouse.hide();
			FlxG.resetInput();
			_lostFocus = _focus.visible = false;
			stage.frameRate = _flashFramerate;
			FlxG.resumeSounds();
		}
		
		/**
		 * Internal event handler for input and focus.
		 * 
		 * @param	FlashEvent	Flash event.
		 */
		protected function onFocusLost(FlashEvent:Event=null):void
		{
			if((x != 0) || (y != 0))
			{
				x = 0;
				y = 0;
			}
			flash.ui.Mouse.show();
			_lostFocus = _focus.visible = true;
			stage.frameRate = 10;
			FlxG.pauseSounds();
		}
		
		/**
		 * Handles the onEnterFrame call and figures out how many updates and draw calls to do.
		 * 
		 * @param	FlashEvent	Flash event.
		 */
		protected function onEnterFrame(FlashEvent:Event=null):void
		{			
			var mark:uint = getTimer();
			var elapsedMS:uint = mark-_total;
			_total = mark;
			updateSoundTray(elapsedMS);
			if(!_lostFocus)
			{
				_accumulator += elapsedMS;
				if(_accumulator > _maxAccumulation)
					_accumulator = _maxAccumulation;
				while(_accumulator >= _step)
				{
					step();
					_accumulator = _accumulator - _step; 
				}
				
				FlxBasic._VISIBLECOUNT = 0;
				draw();
				
				if(_debuggerUp)
				{
					_debugger.perf.flash(elapsedMS);
					_debugger.perf.visibleObjects(FlxBasic._VISIBLECOUNT);
					_debugger.perf.update();
					_debugger.watch.update();
				}
			}
		}

		/**
		 * If there is a state change requested during the update loop,
		 * this function handles actual destroying the old state and related processes,
		 * and calls creates on the new state and plugs it into the game object.
		 */
		protected function switchState():void
		{ 
			//Basic reset stuff
			FlxG.resetCameras();
			FlxG.resetInput();
			FlxG.destroySounds();
			FlxG.clearBitmapCache();
			
			//Clear the debugger overlay's Watch window
			if(_debugger != null)
				_debugger.watch.removeAll();
			
			// Notify everybody about the state switch.
			FlxG.signals.beforeStateSwitch.dispatch();
			
			//Destroy the old state (if there is an old state)
			if(_state != null)
				_state.destroy();
			
			//Finally assign and create the new state
			_state = _requestedState;
			_state.create();
		}
		
		/**
		 * This is the main game update logic section.
		 * The onEnterFrame() handler is in charge of calling this
		 * the appropriate number of times each frame.
		 * This block handles state changes, replays, all that good stuff.
		 */
		protected function step():void
		{
			//handle game reset request
			if(_requestedReset)
			{
				_requestedReset = false;
				_requestedState = new _iState();

				FlxG.reset();
			}
			
			//handle state switching requests
			if(_state != _requestedState)
				switchState();
			
			//finally actually step through the game physics
			FlxBasic._ACTIVECOUNT = 0;
			
			FlxG.updateInput();
			update();
			FlxG.mouse.wheel = 0;
			
			if(_debuggerUp)
				_debugger.perf.activeObjects(FlxBasic._ACTIVECOUNT);
		}

		/**
		 * This function just updates the soundtray object.
		 */
		protected function updateSoundTray(MS:Number):void
		{
			//animate stupid sound tray thing
			
			if(_soundTray != null)
			{
				if(_soundTrayTimer > 0)
					_soundTrayTimer -= MS/1000;
				else if(_soundTray.y > -_soundTray.height)
				{
					_soundTray.y -= (MS/1000)*FlxG.height*2;
					if(_soundTray.y <= -_soundTray.height)
					{
						_soundTray.visible = false;
						
						//Save sound preferences
						var soundPrefs:FlxSave = new FlxSave();
						if(soundPrefs.bind("flixel"))
						{
							if(soundPrefs.data.sound == null)
								soundPrefs.data.sound = new Object;
							soundPrefs.data.sound.mute = FlxG.mute;
							soundPrefs.data.sound.volume = FlxG.volume;
							soundPrefs.close();
						}
					}
				}
			}
		}
		
		/**
		 * This function is called by step() and updates the actual game state.
		 * May be called multiple times per "frame" or draw call.
		 */
		protected function update():void
		{			
			var mark:uint = getTimer();
			
			FlxG.elapsed = FlxG.timeScale*(_step/1000);
			FlxG.updateSounds();
			FlxG.signals.preUpdate.dispatch();
			_state.update();
			FlxG.updateCameras();
			
			if(_debuggerUp)
				_debugger.perf.flixelUpdate(getTimer()-mark);
		}
		
		/**
		 * Goes through the game state and draws all the game objects and special effects.
		 */
		protected function draw():void
		{
			var mark:uint = getTimer();
			_render.step(_state);
			FlxG.signals.postDraw.dispatch();

			if(_debuggerUp)
				_debugger.perf.flixelDraw(getTimer()-mark);
		}
		
		/**
		 * Used to instantiate the guts of the flixel game object once we have a valid reference to the root.
		 * 
		 * @param	FlashEvent	Just a Flash system event, not too important for our purposes.
		 */
		protected function create(FlashEvent:Event):void
		{
			if(root == null)
				return;
			removeEventListener(Event.ADDED_TO_STAGE, create);
			_total = getTimer();
			
			//Set up the view window and double buffering
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.frameRate = _flashFramerate;
			
			//Add basic input event listeners and mouse container
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			addChild(_mouse);
			
			//Let mobile devs opt out of unnecessary overlays.
			if(!FlxG.mobile)
			{
				//Debugger overlay
				if(FlxG.debug || forceDebugger)
				{
					_debugger = new FlxDebugger(FlxG.width*FlxCamera.defaultZoom,FlxG.height*FlxCamera.defaultZoom);
					addChild(_debugger);
				}
				
				//Volume display tab
				createSoundTray();
				
				//Focus gained/lost monitoring
				stage.addEventListener(Event.DEACTIVATE, onFocusLost);
				stage.addEventListener(Event.ACTIVATE, onFocus);
				createFocusScreen();
			}
			
			// Creates and init the render that will be used to draw things into the screen.
			_render = _useGPU ? new FlxGenome2DRender() : new FlxBlittingRender();
			_render.init(this, onEnterFrame);
		}
		
		/**
		 * Sets up the "sound tray", the little volume meter that pops down sometimes.
		 */
		protected function createSoundTray():void
		{
			_soundTray.visible = false;
			_soundTray.scaleX = 2;
			_soundTray.scaleY = 2;
			var tmp:Bitmap = new Bitmap(new BitmapData(80,30,true,0x7F000000));
			_soundTray.x = (FlxG.width/2)*FlxCamera.defaultZoom-(tmp.width/2)*_soundTray.scaleX;
			_soundTray.addChild(tmp);
			
			var text:TextField = new TextField();
			text.width = tmp.width;
			text.height = tmp.height;
			text.multiline = true;
			text.wordWrap = true;
			text.selectable = false;
			text.embedFonts = true;
			text.antiAliasType = AntiAliasType.NORMAL;
			text.gridFitType = GridFitType.PIXEL;
			text.defaultTextFormat = new TextFormat("system",8,0xffffff,null,null,null,null,null,"center");;
			_soundTray.addChild(text);
			text.text = "VOLUME";
			text.y = 16;
			
			var bx:uint = 10;
			var by:uint = 14;
			_soundTrayBars = new Array();
			var i:uint = 0;
			while(i < 10)
			{
				tmp = new Bitmap(new BitmapData(4,++i,false,0xffffff));
				tmp.x = bx;
				tmp.y = by;
				_soundTrayBars.push(_soundTray.addChild(tmp));
				bx += 6;
				by--;
			}
			
			_soundTray.y = -_soundTray.height;
			_soundTray.visible = false;
			addChild(_soundTray);
			
			//load saved sound preferences for this game if they exist
			var soundPrefs:FlxSave = new FlxSave();
			if(soundPrefs.bind("flixel") && (soundPrefs.data.sound != null))
			{
				if(soundPrefs.data.sound.volume != null)
					FlxG.volume = Number(soundPrefs.data.sound.volume);
				if(soundPrefs.data.sound.mute != null)
					FlxG.mute = Boolean(soundPrefs.data.sound.mute);
				soundPrefs.destroy();
			}
		}
		
		/**
		 * Sets up the darkened overlay with the big white "play" button that appears when a flixel game loses focus.
		 */
		protected function createFocusScreen():void
		{
			var gfx:Graphics = _focus.graphics;
			var screenWidth:uint = FlxG.width*FlxCamera.defaultZoom;
			var screenHeight:uint = FlxG.height*FlxCamera.defaultZoom;
			
			//draw transparent black backdrop
			gfx.moveTo(0,0);
			gfx.beginFill(0,0.5);
			gfx.lineTo(screenWidth,0);
			gfx.lineTo(screenWidth,screenHeight);
			gfx.lineTo(0,screenHeight);
			gfx.lineTo(0,0);
			gfx.endFill();
			
			//draw white arrow
			var halfWidth:uint = screenWidth/2;
			var halfHeight:uint = screenHeight/2;
			var helper:uint = FlxMath.min(halfWidth,halfHeight)/3;
			gfx.moveTo(halfWidth-helper,halfHeight-helper);
			gfx.beginFill(0xffffff,0.65);
			gfx.lineTo(halfWidth+helper,halfHeight);
			gfx.lineTo(halfWidth-helper,halfHeight+helper);
			gfx.lineTo(halfWidth-helper,halfHeight-helper);
			gfx.endFill();
			
			var logo:Bitmap = new ImgLogo();
			logo.scaleX = int(helper/10);
			if(logo.scaleX < 1)
				logo.scaleX = 1;
			logo.scaleY = logo.scaleX;
			logo.x -= logo.scaleX;
			logo.alpha = 0.35;
			_focus.addChild(logo);

			addChild(_focus);
		}
	}
}
