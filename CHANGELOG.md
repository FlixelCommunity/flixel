# Flixel v3.0

This version introduces some major new features, improvements and re-organization of the code. It is no longer reverse compatible with projects that use Flixel v2.56 or below because of the new package structure, but almost all classes, methods and parameters are the same.

#### New Features

New plugin system based on `FlxSignals` ([#121](https://github.com/FlixelCommunity/flixel/issues/121))  

New `FlxRandom` pseudo-random number generator available as `FlxG.random` ([#207](https://github.com/FlixelCommunity/flixel/pull/207)) 

New `FlxDebugger` available as `FlxG.debugger` ([#217](https://github.com/FlixelCommunity/flixel/issues/217))

The replay functionality is now a plugin (disabled by default, use `FlxG.addPlugin(new FlxReplay())` to activate) ([#213](https://github.com/FlixelCommunity/flixel/pull/213))

New plugin for interactive debugging ([#206](https://github.com/FlixelCommunity/flixel/issues/206))

New experimental GPU render powered by [Genome2D](https://github.com/pshtif/Genome2D-Core) ([#90](https://github.com/FlixelCommunity/flixel/issues/90))

#### Improvements

Replicated code in debugger has been refactored into `FlxToolbar` ([#157](https://github.com/FlixelCommunity/flixel/issues/157))

#### Bugfixes

Fix FlxTilemap can't draw one-column tilemap  ([#212](https://github.com/FlixelCommunity/flixel/issues/212))
 
#### Repository changes

Organize `FlxG` and `FlxU` a tad better ([#208](https://github.com/FlixelCommunity/flixel/pull/208), [#142](https://github.com/FlixelCommunity/flixel/pull/142))

Move static constants on path following from `FlxObject` to `FlxPath` ([#112](https://github.com/FlixelCommunity/flixel/pull/112)))

Change main package from `org.flixel` to just `flixel` ([#194](https://github.com/FlixelCommunity/flixel/issues/194))

Organize Flixel's classes into several, more logically organized packages ([#194](https://github.com/FlixelCommunity/flixel/issues/194))

Rename `FlxAnim` to `FlxAnimation` ([#205](https://github.com/FlixelCommunity/flixel/issues/194))
