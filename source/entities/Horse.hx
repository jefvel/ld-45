package entities;

import flixel.FlxSprite;

class Horse extends FlxSprite {
    
    override public function new() {
        super();
        loadGraphic(AssetPaths.horse__png);
        offset.set(32, 50);
    }

    var totalTime: Float = 0.0;
    override public function update(elapsed: Float) {
        totalTime += elapsed;
        var wobbliness = Math.min(100, cast(velocity, flixel.math.FlxVector).length);
        offset.set(32, 50 + (Math.sin(elapsed * 100.0) - 1.0) * wobbliness * 0.1);
        super.update(elapsed);
    }
}