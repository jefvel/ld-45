package entities;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxG;

class Player extends FlxGroup {
    private var x: Float = 0;
    private var y: Float = 0;
    private var destLambda: Float = 6;

    private var speed = 67;
    public var arm: Arm;
    private var horse: Horse;
    private var body: FlxSprite;

    private var armRotation: Float;

    private var horseDrag = 370.0;
    private var shotRecoil = 190.0;

    // Horse legs
    var leg1: FlxSprite;
    var leg2: FlxSprite;
    var leg3: FlxSprite;
    var leg4: FlxSprite;

    override public function new() {
        super();
        horse = new Horse();
        horse.mass = 100.0;
        horse.drag.set(horseDrag, horseDrag);

        leg1 = new FlxSprite(null, null, AssetPaths.horseleg__png);
        leg1.offset.set(5, 1);
        leg1.origin.set(5, 1);
        add(leg1);
        leg2 = new FlxSprite(null, null, AssetPaths.horseleg__png);
        leg2.offset.set(5, 1);
        leg2.origin.set(5, 1);
        add(leg2);

        add(horse);

        leg3 = new FlxSprite(null, null, AssetPaths.horseleg__png);
        leg3.offset.set(5, 1);
        leg3.origin.set(5, 1);
        add(leg3);
        leg4 = new FlxSprite(null, null, AssetPaths.horseleg__png);
        leg4.offset.set(5, 1);
        leg4.origin.set(5, 1);
        add(leg4);

        body = new FlxSprite();
        body.loadGraphic(AssetPaths.sheriff__png);
        body.offset.set(23, 55);
        add(body);

        arm = new Arm();
        add(arm);
    }

    function wobbGet(wobbliness:Float, offset: Float) {
        return wobbliness * Math.sin(offset + totalTime * 20.0 + 0.4 * (Math.random() - 0.5)) * 0.3;
    }

    var totalTime = 0.0;
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        totalTime += elapsed;
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

        body.x = horse.x;
        body.y = horse.y - 25;
        body.flipX = horse.flipX;

        var wobbliness = cast(horse.velocity, flixel.math.FlxVector).length;


        arm.angle = armRotation / Math.PI * 180;

        leg1.x = horse.x - 15;
        leg1.y = horse.y + 3;
        leg1.angle = wobbGet(wobbliness, 2.0);


        leg2.x = horse.x + 28;
        leg2.y = horse.y + 3;
        leg2.angle = wobbGet(wobbliness, 4.0);

        leg3.x = horse.x - 20;
        leg3.y = horse.y + 5;
        leg3.angle = wobbGet(wobbliness, 1.2);

        leg4.x = horse.x + 23;
        leg4.y = horse.y + 8;
        leg4.angle = wobbGet(wobbliness, 5.0);

        leg1.flipX = leg2.flipX = leg3.flipX = leg4.flipX = horse.flipX;

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