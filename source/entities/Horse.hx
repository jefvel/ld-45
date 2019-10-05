package entities;

import flixel.FlxSprite;

class Horse extends FlxSprite {
    
    override public function new() {
        super();
        loadGraphic(AssetPaths.horse__png);
     
        offset.set(32, 50);
    }
}