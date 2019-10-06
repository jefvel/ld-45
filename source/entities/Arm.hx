package entities;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Arm extends FlxSprite {
    
    public var muzzlePos = new flixel.math.FlxPoint(60, 11);
    override public function new() {
        super();
        loadGraphic(AssetPaths.arm__png);
        origin.set(5, 16);
    }

    public function setMoveDest(x:Float, y:Float) {

    }

    private static var zeroPoint = FlxPoint.get();
    public function getMuzzleWorldPos() {
        var r = angle / 180.0 * Math.PI;
        var p = FlxPoint.get(x + origin.x, y + origin.y);

        var d = flixel.math.FlxVector.get(muzzlePos.x - origin.x, muzzlePos.y - origin.y);
        d.rotate(zeroPoint, r / Math.PI * 180);

        p.x += d.x;
        p.y += d.y;
        return p;
    }
}