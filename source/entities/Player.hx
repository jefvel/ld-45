package entities;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

class Player extends FlxGroup {
    private var x: Float = 0;
    private var y: Float = 0;
    private var destLambda: Float = 6;

    private var speed = 67;
    public var arm: Arm;
    private var horse: Horse;

    private var armRotation: Float;

    private var horseDrag = 370.0;
    private var shotRecoil = 190.0;

    override public function new() {
        super();
        horse = new Horse();
        horse.mass = 100.0;
        horse.drag.set(horseDrag, horseDrag);
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

        arm.x = horse.x;
        arm.y = horse.y - 60;

        arm.angle = armRotation / Math.PI * 180;
	}

    public function shoot(x:Float, y:Float) {
        var d = new flixel.math.FlxVector(arm.x - x, arm.y - y);
        d.normalize();
        d.scale(shotRecoil);
        horse.velocity.add(d.x, d.y);
        armRotation = Math.atan2(y - arm.y, x - arm.x);
    }

    public function setPosition(x:Float, y:Float) {
        horse.x = x;
        horse.y = y;
    }
}