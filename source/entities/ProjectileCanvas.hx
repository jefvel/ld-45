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
    var bulletLifetime = 0.2;

    public function new() {
        super();
        shots = [];
        this.scrollFactor.set(0, 0);
        makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    }

    public override function update(elapsed: Float) {
        super.update(elapsed);
        this.fill(FlxColor.TRANSPARENT);
        var px = FlxG.camera.scroll.x;
        var py = FlxG.camera.scroll.y;
        var lineStyle:LineStyle = { color: FlxColor.WHITE, thickness: 4, capsStyle: openfl.display.CapsStyle.SQUARE };
        for (shot in shots) {
            var lt = shot.lifeTime / bulletLifetime;
            lineStyle.color.alpha = Std.int(255 * lt);
            lineStyle.thickness = 2 + (1.0 - lt) * 2;
            this.drawLine(shot.x1 - px, shot.y1 - py, shot.x2 - px, shot.y2 - py, lineStyle);
            shot.lifeTime -= elapsed;
            if (shot.lifeTime <= 0) {
                shots.remove(shot);
            }
        }
        this.drawLine(-10.0, -10.0, -10.0, -10.0);
    }

    public function addShot(x1, y1, x2, y2) {
        shots.push({
            x1: x1,
            y1: y1,
            x2: x2,
            y2: y2,
            lifeTime: bulletLifetime,
        });
    }
}