package entities;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.FlxG;

class Player extends FlxSpriteGroup {
    private var destLambda: Float = 6;

    private var speed = 67;
    public var arm: Arm;
    private var horse: Horse;
    public var body: entities.Person;

    private var armRotation: Float;

    private var horseDrag = 370.0;
    private var shotRecoil = 190.0;

    // Horse legs
    var leg1: FlxSprite;
    var leg2: FlxSprite;
    var leg3: FlxSprite;
    var leg4: FlxSprite;

    var shadow: FlxSprite;

    var margin: Float = 64;
    var offsetY = 25;

    override public function new() {
        super();

        maxVelocity.set(500, 500); 
        mass = 100.0;
        drag.set(horseDrag, horseDrag);

        shadow = new FlxSprite(null, null, AssetPaths.shadow_big__png);
        shadow.y = 25 + offsetY;
        shadow.x = -20;
        add(shadow);

        leg1 = new FlxSprite(null, null, AssetPaths.horseleg__png);
        leg1.offset.set(5, 1);
        leg1.origin.set(5, 1);
        add(leg1);
        leg2 = new FlxSprite(null, null, AssetPaths.horseleg__png);
        leg2.offset.set(5, 1);
        leg2.origin.set(5, 1);
        add(leg2);

        horse = new Horse();
        horse.y = offsetY;
        add(horse);

        leg3 = new FlxSprite(null, null, AssetPaths.horseleg__png);
        leg3.offset.set(5, 1);
        leg3.origin.set(5, 1);
        add(leg3);

        leg4 = new FlxSprite(null, null, AssetPaths.horseleg__png);
        leg4.offset.set(5, 1);
        leg4.origin.set(5, 1);
        add(leg4);

        body = new entities.Person();
        body.personType = Player;
        body.loadGraphic(AssetPaths.sheriff__png);
        body.offset.set(23, 55);
        add(body);

        arm = new Arm();
        add(arm);
    }

    function wobbGet(wobbliness:Float, offset: Float, scale:Float = 1.0) {
        return wobbliness * Math.sin(offset + scale * totalTime * 20.0 + 0.4 * (Math.random() - 0.5)) * 0.3;
    }

    var totalTime = 0.0;
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        totalTime += elapsed;

        if (y < GameData.SkyLimit) {
            y = GameData.SkyLimit;
            velocity.y *= 0.1;
        }

        if (Math.abs(this.velocity.x) > 2) {
           horse.flipX = this.velocity.x < 0;
        }

        arm.x = x;
        arm.y = y - 60 + offsetY;

        var wobbliness = cast(velocity, flixel.math.FlxVector).length;

        body.x = x;
        body.y = y - 25 + offsetY;
        body.flipX = horse.flipX;
        body.angle = wobbGet(wobbliness * 0.5, 2.1, 0.9) * 0.1;

        arm.angle = armRotation / Math.PI * 180;

        leg1.x = x - 15;
        leg1.y = y + 3 + offsetY;
        leg1.angle = wobbGet(wobbliness, 2.0);

        leg2.x = x + 28;
        leg2.y = y + 3 + offsetY;
        leg2.angle = wobbGet(wobbliness, 4.0);

        leg3.x = x - 20;
        leg3.y = y + 5 + offsetY;
        leg3.angle = wobbGet(wobbliness, 1.2);

        leg4.x = x + 23;
        leg4.y = y + 8 + offsetY;
        leg4.angle = wobbGet(wobbliness, 5.0);

        leg1.flipX = leg2.flipX = leg3.flipX = leg4.flipX = horse.flipX;

        if (x < 0 + margin) {
            x = margin;
        }
        if (x > GameData.WorldWidth - margin) {
            x = GameData.WorldWidth - margin;
        }
        if (y > GameData.WorldHeight - margin * 2) {
            y = GameData.WorldHeight - margin * 2;
        }
	}

    public function shoot(x:Float, y:Float) {
        var d = new flixel.math.FlxVector(arm.x - x, arm.y - y);
        d.normalize();
        d.scale(shotRecoil);
        velocity.add(d.x, d.y);
        armRotation = Math.atan2(y - arm.y, x - arm.x);
    }
}