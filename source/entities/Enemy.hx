package entities;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;

enum EnemyState {
    Moving;
    Resting;
    Shooting;
    Aiming;
    Looting;
    Dead;
    Hurt;
    None;
}

class Enemy extends entities.Person {
    var curState = None;

    var aimTimeLeft = 0.0;
    var hurtTimeLeft = 0.0;

    var aimPosX = 0.0;
    var aimPosY = 0.0;
    
    var gunPosX = 29;
    var gunPosY = 23;

    // Shooting
    var shootableEntities:Array<entities.Person>;
	var projectileCanvas: ProjectileCanvas;
    var shootTarget: entities.Person;
    var reloaded = true ;
    var reloadTimer: FlxTimer;
	var gunShotSound: FlxSound;

    // Movement
    var destX: Float = 0;
    var destY: Float = 0;
    var destLambdaSquared: Float = 5 * 5;
    var speed: Float = 50;
    var shotRecoil = 120.0;
    var enemyDrag = 1.0;
    var restTimer: FlxTimer;

    var bulletID = -1;
    
    override public function new(peopleToShootAt) {
        super();
        personType = Enemy;
        this.health = GameData.EnemyHealth;

        shootableEntities = peopleToShootAt;

        loadGraphic(AssetPaths.enemy__png, true, 32, 64);
        animation.add("walk", [0, 1], 3, true);
        animation.add("idle", [2, 3], 1, true);
        animation.add("aim", [4], 1, false);
        animation.add("hurt", [5], 1, true);

		gunShotSound = FlxG.sound.load(AssetPaths.gunshot__ogg);
     
        offset.set(16, 48);
        updateHitbox();
        drag.set(enemyDrag, enemyDrag);
		
        reloadTimer = new FlxTimer();
        
        restTimer = new FlxTimer();
        restTimer.onComplete = restTimerComplete;
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        y = Math.max(y, GameData.SkyLimit);

        switch curState {
            case Resting:
                animation.play("idle");
                if (scanForTarget()) {
                    prepareForShot(shootTarget);
                }
            case Aiming:
                animation.play("aim");
                velocity.set(0, 0);
                aimTimeLeft -= elapsed;
                if (aimTimeLeft <= 0) {
                    shoot();
                }
            case Shooting:
                animation.play("aim");
                if (scanForTarget()) {
                    prepareForShot(shootTarget);
                } else {
                    move();
                }
            case Looting:
            case Dead:
            case Hurt:
                hurtTimeLeft -= elapsed;
                velocity.set(0, 0);
                if (hurtTimeLeft <= 0) {
                    rest();
                }
            case Moving:
                if (scanForTarget()) {
                    prepareForShot(shootTarget);
                } else {
                    setMoveDest(
                        destX,
                        destY
                    );
                    var dx = destX - x;
                    var dy = destY - y;
                    var d = (dy * dy + dx * dx);
                    if (d < destLambdaSquared) {
                        this.velocity.set(0, 0);
                        // Half chance to rest or keep moving
                        if (Math.random() > 0.5) {
                            rest();
                        } else {
                            move();
                        }
                    }
                }
            default:
                move();
        }
	}

    public function rest() {
        curState = Resting;
        animation.play("idle");
        restTimer.start(Math.random() * 10.0, restTimerComplete, 1);
    }
    
    public function move() {
        animation.play("walk");
        curState = Moving;

        var yPos = Math.random() * FlxG.height;
        if (yPos < GameData.SkyLimit) {
            yPos = GameData.SkyLimit;
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

    public override function hurt(amount: Float) {
        super.hurt(amount);
        animation.play("hurt");
        hurtTimeLeft = GameData.EnemyHurtRecoveryTime;
        if (bulletID != -1) {
            projectileCanvas.cancelShot(bulletID);
            bulletID = -1;
        }
        curState = Hurt;
    }

    public function setMoveDest(x:Float, y:Float) {
        destX = x;
        destY = y;

        // Calculate speed
        var dx = x - this.x;
        var dy = y - this.y;
        var d = (dy * dy + dx * dx);
        if (d < destLambdaSquared) {
            dx = dy = 0;
        } else {
            dx /= d;
            dy /= d;
            this.flipX = dx < 0;
        }
        this.velocity.set(speed * dx, speed * dy);
    }

    public function scanForTarget(): Bool {
        if (checkTarget(shootTarget)) {
            return true;
        } else {
            for (e in shootableEntities) {
                if (checkTarget(e)) {
                    shootTarget = e;
                    return true;
                }
            }
        }
        return false;
    }

    public function checkTarget(entity: FlxSprite = null): Bool {
        if (entity != null) {
            var dx = entity.x - this.x;
            var dy = entity.y - this.y;
            var d = (dy * dy + dx * dx);
            return d < GameData.EnemyGunRange * GameData.EnemyGunRange;
        }
        return false;
    }

    public function setProjectileCanvas(canvas: ProjectileCanvas) {
        this.projectileCanvas = canvas;
    }

    private function prepareForShot(target: entities.Person) {
        if (!reloaded) {
            return;
        }
        aimTimeLeft = GameData.EnemyAimTime;
        curState = Aiming;
        aimPosX = target.x;
        aimPosY = target.y;
        bulletID = projectileCanvas.addShotPreview(x + (flipX ? 32 - gunPosX : gunPosX), y + gunPosY, aimPosX, aimPosY, GameData.EnemyAimTime);
        flipX = (aimPosX < x);
    }

    private function shoot() {
        animation.play("aim");
        this.velocity.set(0, 0);
        if (this.shootTarget == null) {
            return;
        }
        
        if (this.curState != Shooting) {
            this.curState = Shooting;
        }

        if (reloaded) {
            // Shoot
            //var worldPos = shootTarget.getPosition();
            var worldPos = FlxPoint.get(aimPosX, aimPosY);
            var gunPos = FlxPoint.get(x + (flipX ? 32 - gunPosX : gunPosX), y + gunPosY);
            var v = flixel.math.FlxVector.get(worldPos.x - x, worldPos.y - y);
            /*
            v.normalize();
            v.scale(500);
            */


            var tpos = FlxPoint.get(x + v.x, y + v.y);

            var target: entities.Person = null;
            var d = Math.POSITIVE_INFINITY;
            for (npc in shootableEntities) {
                var dist = ShotTools.lineHitsSprite(gunPos, tpos, npc);
                if (dist < d) {
                    d = dist;
                    target = npc;
                }
            }

            if (target != null) {
                ShotTools.NpcHitSignal.dispatch(target);
                v.scale(d);
                tpos.x = gunPos.x + v.x;
                tpos.y = gunPos.y + v.y;
			}
                
			gunShotSound.stop();
			gunShotSound.play();

            projectileCanvas.addShot(gunPos.x, gunPos.y, tpos.x, tpos.y);

            reloaded = false;
            reloadTimer.start(GameData.EnemyReloadTime, reloadTimerComplete, 1);
            
            shootTarget = null;
        }
    }

    function reloadTimerComplete(timer:FlxTimer) {
        reloaded = true;
    }

    function restTimerComplete(timer:FlxTimer) {
        move();
    }
}