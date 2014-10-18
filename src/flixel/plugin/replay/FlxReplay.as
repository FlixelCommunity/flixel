package flixel.plugin.replay
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flixel.FlxG;
	import flixel.FlxState;
	import flixel.plugin.FlxPlugin;
	import flixel.system.debug.FlxDebugger;
	import flixel.system.debug.VCR;

	/**
	 * The replay object both records and replays game recordings,
	 * as well as handle saving and loading replays to and from files.
	 * Gameplay recordings are essentially a list of keyboard and mouse inputs,
	 * but since Flixel is fairly deterministic, we can use these to play back
	 * recordings of gameplay with a decent amount of fidelity.
	 * 
	 * @author	Adam Atomic
	 * 
	 * Adaptation by Fernando Bevilacqua (dovyski@gmail.com)
	 */
	public class FlxReplay implements FlxPlugin
	{
		/**
		 * The random number generator seed value for this recording.
		 */
		public var seed:Number;
		/**
		 * The current frame for this recording.
		 */
		public var frame:int;
		/**
		 * The number of frames in this recording.
		 */
		public var frameCount:int;
		/**
		 * Whether the replay has finished playing or not.
		 */
		public var finished:Boolean;
		
		/**
		 * Internal container for all the frames in this replay.
		 */
		protected var _frames:Array;
		/**
		 * Internal tracker for max number of frames we can fit before growing the <code>_frames</code> again.
		 */
		protected var _capacity:int;
		/**
		 * Internal helper variable for keeping track of where we are in <code>_frames</code> during recording or replay.
		 */
		protected var _marker:int;
		/**
		 * Container for the record, stop and play buttons.
		 */
		protected var _vcr:VCR;
		
		/**
		 * Flag for whether a playback of a recording was requested.
		 */
		internal var _replayRequested:Boolean;
		/**
		 * Flag for whether a new recording was requested.
		 */
		internal var _recordingRequested:Boolean;
		/**
		 * Flag for whether a replay is currently playing.
		 */
		internal var _replaying:Boolean;
		/**
		 * Flag for whether a new recording is being made.
		 */
		internal var _recording:Boolean;
		/**
		 * Array that keeps track of keypresses that can cancel a replay.
		 * Handy for skipping cutscenes or getting out of attract modes!
		 */
		internal var _replayCancelKeys:Array;
		/**
		 * Helps time out a replay if necessary.
		 */
		internal var _replayTimer:int;
		/**
		 * This function, if set, is triggered when the callback stops playing.
		 */
		internal var _replayCallback:Function;
		
		/**
		 * Instantiate a new replay object.  Doesn't actually do much until you call create() or load().
		 */
		public function FlxReplay()
		{
			seed = 0;
			frame = 0;
			frameCount = 0;
			finished = false;
			_frames = null;
			_capacity = 0;
			_marker = 0;
			
			_replayRequested = false;
			_recordingRequested = false;
			_replaying = false;
			_recording = false;
			
			// Add buttons to record, stop, pause, etc.
			_vcr = new VCR();
			_vcr.x = (FlxG.debugger.width - _vcr.width/2)/2;
			_vcr.y = 2;
			FlxG.debugger.addOverlay(_vcr);
			
			// Tell Flixel to call handlePreUpdate() before the current state is updated.
			FlxG.signals.preUpdate.add(handlePreUpdate);
			
			// Subscribe to state switch events
			FlxG.signals.beforeStateSwitch.add(handleStateSwitch);
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			destroyFrames();
			
			_vcr.destroy();
			FlxG.debugger.removeOverlay(_vcr);
			_vcr = null;
			
			FlxG.signals.preUpdate.remove(handlePreUpdate);
			FlxG.signals.beforeStateSwitch.remove(handleStateSwitch);
		}
		
		/**
		 * Destroys any existing frames to prepare for a new gameplay recording.
		 */
		protected function destroyFrames():void
		{
			if(_frames != null)
			{
				var i:int = frameCount-1;
				while(i >= 0)
					(_frames[i--] as FrameRecord).destroy();
				_frames = null;
			}
		}
		
		/**
		 * Create a new gameplay recording.  Requires the current random number generator seed.
		 * 
		 * @param	Seed	The current seed from the random number generator.
		 */
		public function create(Seed:Number):void
		{
			destroyFrames();
			init();
			seed = Seed;
			rewind();
		}
		
		/**
		 * Load replay data from a <code>String</code> object.
		 * Strings can come from embedded assets or external
		 * files loaded through the debugger overlay. 
		 * 
		 * @param	FileContents	A <code>String</code> object containing a gameplay recording.
		 */
		public function load(FileContents:String):void
		{
			init();
			
			var lines:Array = FileContents.split("\n");
			
			seed = Number(lines[0]);
			
			var line:String;
			var i:uint = 1;
			var l:uint = lines.length;
			while(i < l)
			{
				line = lines[i++] as String;
				if(line.length > 3)
				{
					_frames[frameCount++] = new FrameRecord().load(line);
					if(frameCount >= _capacity)
					{
						_capacity *= 2;
						_frames.length = _capacity;
					}
				}
			}
			
			rewind();
		}
		
		/**
		 * Common initialization terms used by both <code>create()</code> and <code>load()</code> to set up the replay object.
		 */
		protected function init():void
		{
			_capacity = 100;
			_frames = new Array(_capacity);
			frameCount = 0;
		}
		
		/**
		 * Save the current recording data off to a <code>String</code> object.
		 * Basically goes through and calls <code>FrameRecord.save()</code> on each frame in the replay.
		 * 
		 * return	The gameplay recording in simple ASCII format.
		 */
		public function save():String
		{
			if(frameCount <= 0)
				return null;
			var output:String = seed+"\n";
			var i:uint = 0;
			while(i < frameCount)
				output += _frames[i++].save() + "\n";
			return output;
		}

		/**
		 * Get the current input data from the input managers and store it in a new frame record.
		 */
		public function recordFrame():void
		{
			var keysRecord:Array = FlxG.keys.record();
			var mouseRecord:MouseRecord = FlxG.mouse.record();
			if((keysRecord == null) && (mouseRecord == null))
			{
				frame++;
				return;
			}
			_frames[frameCount++] = new FrameRecord().create(frame++,keysRecord,mouseRecord);
			if(frameCount >= _capacity)
			{
				_capacity *= 2;
				_frames.length = _capacity;
			}
		}
		
		/**
		 * Get the current frame record data and load it into the input managers.
		 */
		public function playNextFrame():void
		{
			FlxG.resetInput();
			
			if(_marker >= frameCount)
			{
				finished = true;
				return;
			}
			if((_frames[_marker] as FrameRecord).frame != frame++)
				return;
			
			var fr:FrameRecord = _frames[_marker++];
			if(fr.keys != null)
				FlxG.keys.playback(fr.keys);
			if(fr.mouse != null)
				FlxG.mouse.playback(fr.mouse);
		}
		
		/**
		 * Reset the replay back to the first frame.
		 */
		public function rewind():void
		{
			_marker = 0;
			frame = 0;
			finished = false;
		}
		
		/**
		 * Automatically invoked by Flixel before the state is updated.
		 */
		protected function handlePreUpdate():void
		{
			var _step :uint = (FlxG.elapsed * 1000) / FlxG.timeScale;
			
			//handle replay-related requests
			if(_recordingRequested)
			{
				_recordingRequested = false;
				create(FlxG.random.seed);
				_recording = true;
				_vcr.recording();
				FlxG.log("FLIXEL: starting new flixel gameplay record.");
			}
			else if(_replayRequested)
			{
				_replayRequested = false;
				rewind();
				FlxG.random.seed = seed;
				FlxG.ignoreInput = true;
				_vcr.playing();
				_replaying = true;
			}
			
			if(_replaying && !vcr.paused)
			{
				playNextFrame();
				if(_replayTimer > 0)
				{
					_replayTimer -= _step;
					if(_replayTimer <= 0)
					{
						if(_replayCallback != null)
						{
							_replayCallback();
							_replayCallback = null;
						}
						else
							stopReplay();
					}
				}
				if(_replaying && finished)
				{
					stopReplay();
					if(_replayCallback != null)
					{
						_replayCallback();
						_replayCallback = null;
					}
				}
				_vcr.updateRuntime(_step);
			}
			
			if(_recording)
			{
				recordFrame();
				_vcr.updateRuntime(_step);
			}
		}
		
		/**
		 * TODO: add docs
		 */
		protected function handleStateSwitch():void
		{
			_replayTimer = 0;
			_replayCancelKeys = null;
		}
		
		/**
		 * TODO: add docs
		 * 
		 * @param	FlashEvent	Flash keyboard event.
		 */
		protected function handleKeyDown(FlashEvent:KeyboardEvent):void
		{
			if(_replaying && (_replayCancelKeys != null) && (FlashEvent.keyCode != 192) && (FlashEvent.keyCode != 220))
			{
				var replayCancelKey:String;
				var i:uint = 0;
				var l:uint = _replayCancelKeys.length;
				while(i < l)
				{
					replayCancelKey = _replayCancelKeys[i++];
					if((replayCancelKey == "ANY") || (FlxG.keys.getKeyCode(replayCancelKey) == FlashEvent.keyCode))
					{
						if(_replayCallback != null)
						{
							_replayCallback();
							_replayCallback = null;
						}
						else
							stopReplay();
						break;
					}
				}
				return;
			}
		}
		
		/**
		 * TODO: add docs
		 * 
		 * @param	FlashEvent	Flash emouse event.
		 */
		protected function handleMouseDown(FlashEvent:MouseEvent):void
		{
			if(_replaying && (_replayCancelKeys != null))
			{
				var replayCancelKey:String;
				var i:uint = 0;
				var l:uint = _replayCancelKeys.length;
				while(i < l)
				{
					replayCancelKey = _replayCancelKeys[i++] as String;
					if((replayCancelKey == "MOUSE") || (replayCancelKey == "ANY"))
					{
						if(_replayCallback != null)
						{
							_replayCallback();
							_replayCallback = null;
						}
						else
							stopReplay();
						break;
					}
				}
				return;
			}
		}
		
		/**
		 * Load replay data from a string and play it back.
		 * 
		 * @param	Data		The replay that you want to load.
		 * @param	State		Optional parameter: if you recorded a state-specific demo or cutscene, pass a new instance of that state here.
		 * @param	CancelKeys	Optional parameter: an array of string names of keys (see FlxKeyboard) that can be pressed to cancel the playback, e.g. ["ESCAPE","ENTER"].  Also accepts 2 custom key names: "ANY" and "MOUSE" (fairly self-explanatory I hope!).
		 * @param	Timeout		Optional parameter: set a time limit for the replay.  CancelKeys will override this if pressed.
		 * @param	Callback	Optional parameter: if set, called when the replay finishes.  Running to the end, CancelKeys, and Timeout will all trigger Callback(), but only once, and CancelKeys and Timeout will NOT call FlxG.stopReplay() if Callback is set!
		 */
		public function loadReplay(Data:String,State:FlxState=null,CancelKeys:Array=null,Timeout:Number=0,Callback:Function=null):void
		{
			load(Data);
			if(State == null)
				FlxG.resetGame();
			else
				FlxG.switchState(State);
			_replayCancelKeys = CancelKeys;
			_replayTimer = Timeout*1000;
			_replayCallback = Callback;
			_replayRequested = true;
		}
		
		/**
		 * Resets the game or state and replay requested flag.
		 * 
		 * @param	StandardMode	If true, reload entire game, else just reload current game state.
		 */
		public function reloadReplay(StandardMode:Boolean=true):void
		{
			if(StandardMode)
				FlxG.resetGame();
			else
				FlxG.resetState();
			if(frameCount > 0)
				_replayRequested = true;
		}
		
		/**
		 * Stops the current replay.
		 */
		public function stopReplay():void
		{
			_replaying = false;
			_vcr.stopped();
			FlxG.resetInput();
		}
		
		/**
		 * Resets the game or state and requests a new recording.
		 * 
		 * @param	StandardMode	If true, reset the entire game, else just reset the current state.
		 */
		public function recordReplay(StandardMode:Boolean=true):void
		{
			if(StandardMode)
				FlxG.resetGame();
			else
				FlxG.resetState();
			_recordingRequested = true;
		}
		
		/**
		 * Stop recording the current replay and return the replay data.
		 * 
		 * @return	The replay data in simple ASCII format (see <code>FlxReplay.save()</code>).
		 */
		public function stopRecording():String
		{
			_recording = false;
			_vcr.stopped();
			return save();
		}
	}
}
