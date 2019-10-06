package entities;

using flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.util.FlxColor;

typedef Bloodsplatter = {
    var x: Float;
    var y: Float;
    var width: Float;
    var height: Float;
}

class BloodCanvas extends flixel.FlxSprite {
    var bloodsplatters:Array<Bloodsplatter>;
    var bloodsplatterWidth = 20.0;
    var bloodsplatterHeight = 14.0;

    public function new() {
        super();
        bloodsplatters = [];
        this.scrollFactor.set(0, 0);
        makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, true);
    }

    public override function update(elapsed: Float) {
        super.update(elapsed);
        var lineStyle:LineStyle = { color: FlxColor.RED };
        var drawStyle:DrawStyle = { smoothing: true };
        for (blood in bloodsplatters) {
            this.drawEllipse(
                blood.x,
                blood.y,
                blood.width,
                blood.height,
                FlxColor.RED,
                lineStyle,
                drawStyle
            );
        }
    }

    public function addBloodsplatter(x, y) {
        bloodsplatters.push({
            x: x,
            y: y,
            width: bloodsplatterWidth,
            height: bloodsplatterHeight,
        });
    }
}