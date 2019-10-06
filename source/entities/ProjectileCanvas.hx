package entities;

using flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.util.FlxColor;

enum ShotType {
    Preview;
    RealShot;
}

typedef Projectile = {
    var x1: Float;
    var y1: Float;
    var x2: Float;
    var y2: Float;
    var lifeTime: Float;
    var type: ShotType;
    var id: Int;
}


class ProjectileCanvas extends flixel.FlxSprite {
    var shots:Array<Projectile>;
    var bulletLifetime = 0.2;

    var bulletID = 0;

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
            switch (shot.type) {
                case RealShot:
                    lineStyle.color = FlxColor.WHITE;
                case Preview:
                    lineStyle.color = FlxColor.RED;
            }
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

    public function cancelShot(id) {
        for (s in shots) {
            if (s.id == id) {
                shots.remove(s);
                return;
            }
        }
    }

    public function addShotPreview(x1, y1, x2, y2, aimTime) {
        var id = bulletID ++;
        shots.push({
            x1: x1,
            y1: y1,
            x2: x2,
            y2: y2,
            lifeTime: aimTime,
            type: Preview,
            id: id
        });
        return id;
    }

    public function addShot(x1, y1, x2, y2) {
        var id = bulletID ++;
        shots.push({
            x1: x1,
            y1: y1,
            x2: x2,
            y2: y2,
            lifeTime: bulletLifetime,
            type: RealShot,
            id: id
        });
        return id;
    }
}