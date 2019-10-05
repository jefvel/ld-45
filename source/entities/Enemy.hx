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
    Looting;
    Dead;
    None;
}

class Enemy extends FlxSprite {
    var curState = None;

    // Shooting
    public static var shootableEntities = new Array<FlxSprite>();
	var projectileCanvas: ProjectileCanvas;
    var detectRadius: Float = 190;
    var shootTarget: FlxSprite;
    var reloaded = true ;
    var reloadTime: Float = 1.7;
    var reloadTimer: FlxTimer;
	var gunShotSound: FlxSound;
	var crushSound: FlxSound;

    // Movement
    var destX: Float = 0;
    var destY: Float = 0;
    var destLambda: Float = 5;
    var speed: Float = 50;
    var shotRecoil = 120.0;
    var enemyDrag = 1.0;
    var restTimer: FlxTimer;
    
    override public function new() {
        super();
        loadGraphic(AssetPaths.enemy__png);

		gunShotSound = FlxG.sound.load(AssetPaths.gunshot__wav);
		crushSound = FlxG.sound.load(AssetPaths.death__wav);
     
        offset.set(14, 48);
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
                if (scanForTarget()) {
                    shoot();
                }
            case Shooting:
                if (scanForTarget()) {
                    shoot();
                } else {
                    move();
                }
            case Looting:
            case Dead:
            case Moving:
                if (scanForTarget()) {
                    shoot();
                } else {
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
            default:
                move();
        }
	}

    public function rest() {
        curState = Resting;
        restTimer.start(Math.random() * 10.0, restTimerComplete, 1);
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

    public function scanForTarget(): Bool {
        if (checkTarget(shootTarget)) {
            trace(shootTarget);
            return true;
        } else {
            for (e in shootableEntities) {
                if (checkTarget(e)) {
                    shootTarget = e;
                    curState = Shooting;
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
            var d = Math.sqrt(dy * dy + dx * dx);
            return d < detectRadius;
        }
        return false;
    }

    public function setProjectileCanvas(canvas: ProjectileCanvas) {
        this.projectileCanvas = canvas;
    }

    private function shoot() {
        this.velocity.set(0, 0);
        
        if (this.curState != Shooting) {
            this.curState = Shooting;
        }

        if (reloaded) {
            // Shoot
            var worldPos = shootTarget.getPosition();
            var v = new flixel.math.FlxVector(worldPos.x - x, worldPos.y - y);
            v.normalize();
            v.scale(500);

            var gunPos = new FlxPoint(x, y);

            var tpos = new FlxPoint(x + v.x, y + v.y);

            var target: FlxSprite = null;
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
				gunShotSound.stop();
			}
                
			gunShotSound.stop();
			gunShotSound.play();

            projectileCanvas.addShot(gunPos.x, gunPos.y, tpos.x, tpos.y);

            reloaded = false;
            reloadTimer.start(reloadTime, reloadTimerComplete, 1);
            
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