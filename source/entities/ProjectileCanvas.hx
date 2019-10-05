package entities;

using flixel.util.FlxSpriteUtil;

import flixel.FlxG;
import flixel.util.FlxColor;

typedef Projectile = {
    var x1: Float;
    var y1: Float;
    var x2: Float;
    var y2: Float;
    var lifeTime: Float;
}

class ProjectileCanvas extends flixel.FlxSprite {
    var shots:Array<Projectile>;
    public function new() {
        super();
        shots = [];
        this.scrollFactor.set(0, 0);
        makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    }

    public override function update(elapsed: Float) {
        super.update(elapsed);
        fill(FlxColor.TRANSPARENT);
        var lineStyle:LineStyle = { color: FlxColor.WHITE, thickness: 2 };
        for (shot in shots) {
            lineStyle.color.alpha = Std.int(255 * (shot.lifeTime / 0.2));
            drawLine(shot.x1, shot.y1, shot.x2, shot.y2, lineStyle);
            shot.lifeTime -= elapsed;
            if (shot.lifeTime <= 0) {
                shots.remove(shot);
            }
        }
        drawLine(-10.0, -10.0, -10.0, -10.0);
    }

    public function addShot(x1, y1, x2, y2) {
        shots.push({
            x1: x1,
            y1: y1,
            x2: x2,
            y2: y2,
            lifeTime: 0.2,
        });
    }
}