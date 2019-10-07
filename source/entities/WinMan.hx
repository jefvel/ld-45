package entities;

import flixel.FlxSprite;

class WinMan extends FlxSprite {
    public function new() {
        super();
		loadGraphic(AssetPaths.winman__png);
		origin.set(width * 0.5, height - 30);
		offset.set(width * 0.5, height - 30);
		scrollFactor.set(0, 0);
    }

    var t = 0.0;
    public override function update(elapsed:Float) {
        super.update(elapsed);
        t += elapsed * 1.3;
        offset.y = height - 30 + Math.sin(t * 6) * 5;
        angle = Math.sin(t) * 5;
    }
}