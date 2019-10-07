package entities;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;

enum CivilianState {
    Moving;
    Resting;
    Shooting;
    Looting;
    Hurt;
    Dead;
    None;
    Cheering;
}

class Civilian extends entities.Person {
    private var curState = None;

    private var destX: Float = 0;
    private var destY: Float = 0;
    private var destLambda: Float = 5;
    private var speed: Float = 50;

    var hurtTimeLeft = 0.0;
    private var timer: FlxTimer;

    private var timeUntilReady = 0.0;

    private var enemies: Array<entities.Person>;

    private var untilDoneShooting = 0.0;

	var projectileCanvas: ProjectileCanvas;

    var gunShotSound: flixel.system.FlxSound;

    override public function new(enemyArray: Array<entities.Person>, projectiles: ProjectileCanvas) {
        super();
        enemies = enemyArray;
        this.projectileCanvas = projectiles;

        health = GameData.CivHealth;
        personType = Citizen;
        loadGraphic(AssetPaths.civilian__png, true, 32, 64);
        animation.add("walk", [0, 1], 2, true);
        animation.add("idle", [2], 1, true);
        animation.add("shoot", [3], 2, false);
        animation.add("hurt", [4], 2, false);
        animation.add("cheer", [5, 6], 3, true);
     
        offset.set(14, 48);
        updateHitbox();
		
        timer = new FlxTimer();
        timer.onComplete = timerComplete;

		gunShotSound = FlxG.sound.load(AssetPaths.gunshot__ogg);
    }

    public function startCheering() {
        new FlxTimer().start(Math.random() * 0.3, function(e) {
            this.curState = Cheering;
            this.animation.play("cheer");
        });
    }

    var t = 0.0;
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        timeUntilReady -= elapsed;

        health += elapsed * GameData.CivRegen;
        health = Math.min(health, GameData.CivHealth);

        switch curState {
            case Resting:
                animation.play("idle");
                tryShoot();
            case Looting:
            case Dead:
            case Cheering:
                t += elapsed;
                velocity.set(0, 0);
                animation.play("cheer");
                offset.y = Math.sin(t * 20) * 3;
                angle = Math.sin(t * 15) * 10;
            case Shooting: 
                velocity.set(0, 0);
                untilDoneShooting -= elapsed;
                if (untilDoneShooting <= 0) {
                    if (Math.random() > 0.5) {
                        move();
                    }
                }
            case Hurt:
                hurtTimeLeft -= elapsed;
                velocity.set(0, 0);
                if (hurtTimeLeft <= 0) {
                    rest();
                }
            case Moving:
                animation.play("walk");

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

                tryShoot();
            default:
                move();
        }
	}

    public override function hurt(amount: Float) {
        super.hurt(amount);
        animation.play("hurt");
        hurtTimeLeft = GameData.CivHurtRecoveryTime;
        curState = Hurt;
    }

    function tryShoot() {
        if (timeUntilReady > 0) {
            return;
        }

        var r2 = GameData.CivGunRange * GameData.CivGunRange;
        var v = flixel.math.FlxVector.get();

        var target: entities.Person = null;
        var dist = Math.POSITIVE_INFINITY;
        for (e in enemies) {
            v.x = x - e.x;
            v.y = y - e.y;
            if (v.lengthSquared < r2 && v.lengthSquared < dist) {
                target = e;
            }
        }

        if (target == null) {
            return;
        }

        shootAt(target);

    }

    public function shootAt(e: entities.Person) {
        timeUntilReady = GameData.CivReloadTime;
        animation.play("shoot");
        curState = Shooting;
        untilDoneShooting = 0.4;
        ShotTools.NpcHitSignal.dispatch(e);
        projectileCanvas.addShot(x, y, e.x + Math.random() * 20, e.y + Math.random() * 20);
        gunShotSound.play();
    }

    public function rest() {
        curState = Resting;
        timer.start(0.5 + Math.random() * 6.0, timerComplete, 1);
    }

    public function move() {
        curState = Moving;
        var yPos = Math.random() * FlxG.height;
        if (yPos < GameData.SkyLimit) {
            yPos += GameData.SkyLimit;
        }

        var w = GameData.WorldWidth - x;
        var xPos = x + Math.random() * w;
        if (x < GameData.WorldWidth - 300) {
            xPos = x + Math.random() * 150 + 20;
        } else {
            xPos = GameData.WorldWidth - 300 + Math.random() * 300;
        }

        for (e in enemies) {
            if (e.x < x) {
                xPos = x - Math.random() * 50.0;
                break;
            }
        }

        setMoveDest(
            xPos,
            yPos
        );
    }

    public function setMoveDest(x:Float, y:Float) {
        // Store destination
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