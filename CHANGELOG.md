# Flixel v2.56

This version fixes many of Flixel's older bugs, while staying reverse compatible with projects that use Flixel v2.55 (the current version in [AdamAtomic/flixel](https://github.com/AdamAtomic/flixel)).

#### New Features

Add properties `numFrames` and `maxFrames` to `FlxSprite` ([#174](https://github.com/FlixelCommunity/flixel/issues/174))  
Add new `FlxTween` class ([#114](https://github.com/FlixelCommunity/flixel/issues/114))  
Add function to trigger full-screen support ([not complete](https://github.com/FlixelCommunity/flixel/issues/93)) ([#74](https://github.com/FlixelCommunity/flixel/issues/74))  
Make `FlxG.log()` able to split out arrays using `FlxU.formatArray()` ([#74](https://github.com/FlixelCommunity/flixel/issues/74))  
Add optional `ColorMap` parameter to `FlxTilemap.bitmapToCSV()` ([#74](https://github.com/FlixelCommunity/flixel/issues/74))  

#### Improvements

Prevent being able to set a `FlxSprite` to an invalid frame ([#174](https://github.com/FlixelCommunity/flixel/issues/174))  
Prevent errors if `destroy()` is called twice ([#153](https://github.com/FlixelCommunity/flixel/issues/153))  
Log error if invalid Bitmap passed to `FlxG.addBitmap()` ([#127](https://github.com/FlixelCommunity/flixel/issues/127))  
`FlxG.sort()` won't crash if a property is not found ([#116](https://github.com/FlixelCommunity/flixel/issues/116))  
Log error if invalid custom particle class is passed to `FlxEmitter` ([#95](https://github.com/FlixelCommunity/flixel/issues/95))  
Prevent being able to pass `null` to `FlxObject.add()` ([#87](https://github.com/FlixelCommunity/flixel/issues/87))  
`FlxObjects` will now stop when they reach the end of a path ([#85](https://github.com/FlixelCommunity/flixel/issues/85))  
Remove several FlashBuilder/FDT warnings
Remove migration warnings if published with Flash IDE ([#76](https://github.com/FlixelCommunity/flixel/issues/76))  
Add `super.destroy()` to all overridden `destroy()` methods ([#73](https://github.com/FlixelCommunity/flixel/issues/73))  
Add `http://` prefix if user did not in `FlxPreloader.goToMyURL()` ([#71](https://github.com/FlixelCommunity/flixel/issues/71))  

#### Performance Improvements

No need to fill a camera twice if not blending alpha ([#143](https://github.com/FlixelCommunity/flixel/issues/143))  
Remove small performance issue in `FlxG.addBitamp()` ([#96](https://github.com/FlixelCommunity/flixel/issues/96))  
Refactored `FlxObject::preUpdate()` to remove uneccessary code ([#82](https://github.com/FlixelCommunity/flixel/issues/82))  

#### Bugfixes
Fix `FlxGroup#maxSize` ([#184](https://github.com/FlixelCommunity/flixel/issues/184))  
Fix documentation for `FlxText#moves` ([#180](https://github.com/FlixelCommunity/flixel/issues/180))  
Fix `FlxSprite.drawLine()` incorrect behavior when full transparency set in color ([#173](https://github.com/FlixelCommunity/flixel/issues/173))  
Fix `FlxTilemap.overlapsWithCallback` calls callback when no overlapping ([#166](https://github.com/FlixelCommunity/flixel/issues/166))  
Fix `FlxCamera` "jitters" when following a target ([#134](https://github.com/FlixelCommunity/flixel/issues/134))  
Fix `FlxText` and problem with camera zoom ([#119](https://github.com/FlixelCommunity/flixel/issues/119))  
Fix `Mouse.as` doesn't like negative cursor offsets mixed with native Flash ([#117](https://github.com/FlixelCommunity/flixel/issues/117))  
_Major_ cleanup and bug fixing of `FlxSound` ([#114](https://github.com/FlixelCommunity/flixel/issues/114))  , ([#103](https://github.com/FlixelCommunity/flixel/issues/103))  , ([#101](https://github.com/FlixelCommunity/flixel/issues/101))  , ([#92](https://github.com/FlixelCommunity/flixel/issues/92))  , ([#80](https://github.com/FlixelCommunity/flixel/issues/80))  
Fix `FlxObject#(overlaps|overlapsAt)` checking only first element of `FlxGroup` ([#109](https://github.com/FlixelCommunity/flixel/issues/109))  
Fix `FlxTilemap` not clearing variables before `loadMap` ([#102](https://github.com/FlixelCommunity/flixel/issues/102))  
Fix `overlapProcessed` isn't properly cleared in `FlxQuadTree` ([#100](https://github.com/FlixelCommunity/flixel/issues/100))  
Fix `FlxTilemap` ignoring last tiles if `startingIndex > 0` ([#99](https://github.com/FlixelCommunity/flixel/issues/99))  
Add missing usage of `particleClass` in `FlxEmitter` ([#95](https://github.com/FlixelCommunity/flixel/issues/95))  
Fix `FlxTilemap.ray()` result value always `null` ([#84](https://github.com/FlixelCommunity/flixel/issues/84))  
Fix `FlxU.round()` giving incorrect results for negative numbers ([#79](https://github.com/FlixelCommunity/flixel/issues/79))  
Fix `FlxU.formatArray()` includes first element twice ([#77](https://github.com/FlixelCommunity/flixel/issues/77))  
Fix health only initialized in `FlxSprite`, should have been in `FlxObject` ([#74](https://github.com/FlixelCommunity/flixel/issues/74))  
Fix incorrect value for `moves` in `FlxTileblock` and `FlxTilemap` ([#70](https://github.com/FlixelCommunity/flixel/issues/70))  

#### Repository changes

Move source to `src` folder  
Remove documentation (only include it in release builds)  
Add `generate-asdoc.sh` and `generate-swc.sh` utilities  
Add `.gitignore`  
Add `CHANGELOG.md`  

