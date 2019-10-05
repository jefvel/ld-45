package entities;

import flixel.FlxSprite;

class Arm extends FlxSprite {
    
    override public function new() {
        super();
        loadGraphic(AssetPaths.arm__png);
        offset.set(-32, 32);
        origin.set(5, 16);
    }

    public function setMoveDest(x:Float, y:Float) {

    }
}