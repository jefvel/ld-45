package entities;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

class Player extends FlxGroup {
    private var x: Float = 0;
    private var y: Float = 0;
    private var destLambda: Float = 6;

    private var speed = 67;
    private var arm: Arm;
    private var horse: Horse;

    private var armRotation: Float;

    override public function new() {
        super();
        horse = new Horse();
        add(horse);

        arm = new Arm();
        add(arm);
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        /*
        var dx = x - horse.x;
        var dy = y - horse.y;
        var d = Math.sqrt(dy * dy + dx * dx);
        if (d < destLambda) {
            dx = dy = 0;
        } else {
            dx /= d;
            dy /= d;
            horse.flipX = dx < 0;
        }
        
        horse.velocity.set(speed * dx, speed * dy);
        */
        horse.y = Math.max(horse.y, GameData.SkyLimit);

        arm.x = horse.x - 30;
        arm.y = horse.y - 30;
        arm.angle = armRotation / Math.PI * 180 + 180;
	}

    public function setMoveDest(x:Float, y:Float) {
        armRotation = Math.atan2(arm.y - y, arm.x - x);
    }
    public function setPosition(x:Float, y:Float) {
        horse.x = x;
        horse.y = y;
    }
}