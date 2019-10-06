package entities;

using flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.group.FlxGroup;

class BloodSplatter extends FlxSprite {
    public static var ExpiredSignal = new FlxTypedSignal<BloodSplatter->Void>();
    public var lifeSpan = 8.0;
    public var lifeTimer = new FlxTimer();

    override public function new() {
		super();
        lifeTimer.start(lifeSpan, function(timer:FlxTimer) { destroy(); }, 1);
    }
}

class BloodCanvas extends FlxGroup{
    var bloodsplatters:Array<BloodSplatter>;

    public function new() {
        super();
		// BloodSplatter.ExpiredSignal.add(removeBloodsplatter);
    }

    public function addBloodsplatter(x, y) {
        var b = new BloodSplatter();
        b.loadGraphic(AssetPaths.blood_splatters__png, true, 28, 28);
        b.visible = true;
        b.x = x;
        b.y = y;
        b.animation.randomFrame();
        add(b);
    }

    // public function removeBloodsplatter(b:BloodSplatter) {
    //     b.destroy();
    // }
}