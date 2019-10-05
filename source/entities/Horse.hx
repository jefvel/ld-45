package entities;

import flixel.FlxSprite;

class Horse extends FlxSprite {
    
    override public function new() {
        super();
        loadGraphic(AssetPaths.horse__png);
        offset.set(32, 50);
    }

    override public function update(elapsed: Float) {
        super.update(elapsed);
        if (Math.abs(this.velocity.x) > 2) {
           flipX = this.velocity.x < 0;
        }
    }
}