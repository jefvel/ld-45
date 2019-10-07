package entities;

import flixel.FlxSprite;

class WinArm extends FlxSprite {
    public function new() {
        super();
		loadGraphic(AssetPaths.happyarm__png);
		origin.set(width * 0.5, height - 20);
		offset.set(width * 0.5, height - 20);
		scrollFactor.set(0, 0);
    }

    var t = 2.0;
    public override function update(elapsed:Float) {
        super.update(elapsed);
        t += elapsed * 1.6;
        offset.y = height - 20 + Math.sin(t * 6) * 2;
        angle = Math.sin(t) * 5;
    }
}
