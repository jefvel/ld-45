package entities;

import flixel.FlxSprite;
class Barrel extends FlxSprite {
    public var following: FlxSprite;
    var followRadius = 20.0;
    public function new() {
        super();
        loadGraphic(AssetPaths.barrel__png);
        centerOrigin();
    }

    public function depositAndNext(next: Barrel) {
    }

    var f = 0.0;
    public override function update(elapsed: Float) {
        f += elapsed;
        super.update(elapsed);
        angle = Math.sin(f * 2) * 10;
        if (following != null) {
            var dx = following.x + following.offset.x - x;
            var dy = following.y + following.offset.y - y;
            var d = Math.sqrt(dx * dx + dy * dy);
            var follow = (d - followRadius) * 0.3;
            dx /= d;
            dy /= d;
            dx *= follow;
            dy *= follow;
            x += dx;
            y += dy;
        }
    }
}