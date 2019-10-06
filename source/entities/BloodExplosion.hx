package entities;

import haxe.ds.Vector;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import flixel.util.helpers.FlxPointRangeBounds;
import flixel.util.helpers.FlxRangeBounds;
import flixel.util.helpers.FlxBounds;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;

class BloodExplosion extends FlxEmitter {
	public static var BloodHitGroundSignal: FlxTypedSignal<FlxPoint->Void>; // Assign in gamestate
    public static var numParticles = 4;
    static var minParticleScale = 0.2;
    static var maxParticleScale = 0.8;
    static var gravity = 1000.0;
    static var initialSpeed = 500.0;
    static var minLifespan = 1.0;
    
    public var particleTimer: FlxTimer;
    public var goreParticles: Array<FlxParticle>;
    public var initPosY: Float;

    override public function new(X:Float, Y:Float) {
        super(X, Y);
        initPosY = Y;
		maxSize = numParticles;
        _explode = true;
        launchMode = FlxEmitterMode.CIRCLE;
        launchAngle = new FlxBounds<Float>(-135, -45);
        angle = new FlxRangeBounds<Float>(-180, 180);
        angularVelocity = new FlxRangeBounds<Float>(0, 540);
        speed = new FlxRangeBounds(initialSpeed * 0.4, initialSpeed);
        acceleration = new FlxPointRangeBounds(0, gravity);
		
        // Generate particles
        particleTimer = new FlxTimer();
        goreParticles = new Array<FlxParticle>();
		var p:FlxParticle;
		for (i in 0...(Std.int(maxSize))) {
			p = new FlxParticle();
            var scale = Math.max(Math.random() * maxParticleScale, minParticleScale);
			p.loadGraphic(
                AssetPaths.gore_particles__png,
                true,
                Math.floor(width * scale),
                Math.floor(height * scale),
                true
                );
			p.animation.add("disperse", [0,1,2], 5, false);
            add(p);
            
            p.animation.play("disperse");

            goreParticles.push(p);
		}

        particleTimer.start();
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
        var i = goreParticles.length;
        while(--i >= 0) {
            if(particleTimer.finished) {
                BloodExplosion.BloodHitGroundSignal.dispatch(
                    new FlxPoint(goreParticles[i].x, goreParticles[i].y)
                    );
                goreParticles[i].destroy();
                goreParticles.splice(i, 1);
            }
        }
        if (goreParticles.length == 0) {
            destroy();
        }
    }
}