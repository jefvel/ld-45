package entities;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

enum EnemyState {
    Moving;
    Resting;
    Shooting;
    Looting;
    Dead;
    None;
}

class Enemy extends FlxSprite {
    private var curState = None;

    private var destX: Float = 0;
    private var destY: Float = 0;
    private var destLambda: Float = 5;
    private var speed: Float = 50;

    private var timer: FlxTimer;
    
    override public function new() {
        super();
        loadGraphic(AssetPaths.enemy__png);
     
        offset.set(14, 48);
        updateHitbox();
		
        timer = new FlxTimer();
        timer.onComplete = timerComplete;
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        switch curState {
            case Resting:
            case Shooting:
            case Looting:
            case Dead:
            default:
                var dx = destX - x;
                var dy = destY - y;
                var d = Math.sqrt(dy * dy + dx * dx);
                if (d < destLambda) {
                    this.velocity.set(0, 0);
                    // Half chance to rest or keep moving
                    if (Math.random() > 0.5) {
                        rest();
                    } else {
                        move();
                    }
                }
        }
	}

    public function rest() {
        curState = Resting;
        timer.start(Math.random() * 10.0, timerComplete, 1);
    }
    
    public function move() {
        curState = Moving;

        var yPos = Math.random() * FlxG.height;
        if (yPos < GameData.SkyLimit) {
            yPos += GameData.SkyLimit;
        }
        var xPos = Math.random() * GameData.WorldWidth - width;
        if (xPos < 0) {
            xPos += width;
        }
        setMoveDest(
            xPos,
            yPos
        );
    }

    public function setMoveDest(x:Float, y:Float) {
        destX = x;
        destY = y;

        // Calculate speed
        var dx = x - this.x;
        var dy = y - this.y;
        var d = Math.sqrt(dy * dy + dx * dx);
        if (d < destLambda) {
            dx = dy = 0;
        } else {
            dx /= d;
            dy /= d;
            this.flipX = dx < 0;
        }
        this.velocity.set(speed * dx, speed * dy);
    }

    function timerComplete(timer:FlxTimer) {
        move();
    }
}