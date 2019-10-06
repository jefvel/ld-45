package entities;

import flixel.FlxSprite;
import entities.Person.PersonType;

class Gib extends flixel.group.FlxSpriteGroup {
    static inline var BodyLifeTime = 10;
    var lifeTimeLeft: Float;
    var floorY: Float;
    public function new(type: PersonType, x: Float, y: Float) {
        super();
        lifeTimeLeft = BodyLifeTime;
        floorY = y + 64;
        switch(type) {
            case Enemy:
                for (i in 0...5) {
                    var s = new FlxSprite(x, -40 + y + i * 20 + Math.random() * 10);
                    s.loadGraphic(AssetPaths.enemygib__png, true, 32, 32, false);
                    s.health = 20.0 + Math.random() * 5;
                    s.angularVelocity = (-50.0 + Math.random() * 100) * 3.0;
                    s.animation.frameIndex = i;
                    s.acceleration.y = 900.0;
                    s.angularDrag = 40;
                    s.drag.x = 50;
                    s.velocity.set((Math.random() * 100 - 50) * 3.0, -50 - Math.random() * 250);
                    add(s);
                }
            case Player:
            case Citizen:
        }
    }

    public override function update(elapsed: Float) {
        super.update(elapsed);
        lifeTimeLeft -= elapsed;
        for (c in this.iterator()) {
            c.hurt(0.1);
            if (c.y > floorY) {
                c.velocity.y *= -0.8;
                c.velocity.x *= 0.9;
                c.angularVelocity *= 0.5;
            }
        }
        if (lifeTimeLeft <= 0) {
            this.destroy();
        }
    }
}