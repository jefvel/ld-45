package entities;

import flixel.FlxSprite;

class Arm extends FlxSprite {
    
    override public function new() {
        super();
        loadGraphic(AssetPaths.arm__png);
    }

    public function setMoveDest(x:Float, y:Float) {

    }
}