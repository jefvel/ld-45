package entities;

import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.FlxSprite;

class ShotTools {
    static inline var EPS = 0.00000001;
    // Returns Math.POSITIVE_INFINITY if no hit
    static function lineVsLine(a1:FlxPoint, a2: FlxPoint, b1:FlxPoint, b2:FlxPoint, out: FlxPoint): Float {
        var b = new FlxVector(a2.x - a1.x, a2.y - a1.y);
        var d = new FlxVector(b2.x - b1.x, b2.y - b1.y);
        var bDotDPerp = b.x * d.y - b.y * d.x;

        // if b dot d == 0, it means the lines are parallel so have infinite intersection points
        if (bDotDPerp <= EPS) {
            return Math.POSITIVE_INFINITY;
        }

        var c = new FlxVector(b1.x - a1.x, b1.y - a1.y);
        var t = (c.x * d.y - c.y * d.x) / bDotDPerp;
        if (t < 0 || t > 1) {
            return Math.POSITIVE_INFINITY;
        }

        var u = (c.x * b.y - c.y * b.x) / bDotDPerp;
        if (u < 0 || u > 1) {
            return Math.POSITIVE_INFINITY;
        }

        out.x = a1.x + t * b.x;
        out.y = a1.y + t * b.y;

        return t;
    }

    // Test every line in hitbox for intersections, returns Math.POSITIVE_INFINITY if no hit
    public static function lineHitsSprite(a1: FlxPoint, a2: FlxPoint, s: FlxSprite): Float {
        var b1 = new FlxPoint();
        var b2 = new FlxPoint();

        var res = new FlxPoint();
        var max = Math.POSITIVE_INFINITY;

        var hb = s.getHitbox();

        b1.x = hb.left;
        b1.y = hb.top;
        b2.x = hb.right;
        b2.y = hb.top;

        max = Math.min(Math.POSITIVE_INFINITY, lineVsLine(a1, a2, b1, b2, res));

        b1.x = hb.right;
        b1.y = hb.top;
        b2.x = hb.right;
        b2.y = hb.bottom;

        max = Math.min(Math.POSITIVE_INFINITY, lineVsLine(a1, a2, b1, b2, res));

        b1.x = hb.left;
        b1.y = hb.bottom;
        b2.x = hb.right;
        b2.y = hb.bottom;

        max = Math.min(Math.POSITIVE_INFINITY, lineVsLine(a1, a2, b1, b2, res));

        b1.x = hb.left;
        b1.y = hb.top;
        b2.x = hb.left;
        b2.y = hb.bottom;

        max = Math.min(Math.POSITIVE_INFINITY, lineVsLine(a1, a2, b1, b2, res));

        return max;
    }
}