package entities;

import flixel.FlxSprite;

class Arm extends FlxSprite {
    
    override public function new() {
        super();
        loadGraphic(AssetPaths.arm__png);
        origin.set(5, 16);
    }

    public function setMoveDest(x:Float, y:Float) {

    }
}