package entities;

import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.FlxSprite;

class ShotTools {
    static inline var EPS = 0.00000001;
    // Returns Math.POSITIVE_INFINITY if no hit
    static function lineVsLine(a1:FlxPoint, a2: FlxPoint, b1:FlxPoint, b2:FlxPoint, out: FlxPoint): Float {
        var s1_x, s1_y, s2_x, s2_y;
        s1_x = a2.x - a1.x;
        s1_y = a2.y - a1.y;
        s2_x = b2.x - b1.x;
        s2_y = b2.y - b1.y;

        var s, t;
		s = (-s1_y * (a1.x - b1.x) + s1_x * (a1.y - b1.y)) / (-s2_x * s1_y + s1_x * s2_y);
		t = (s2_x * (a1.y - b1.y) - s2_y * (a1.x - b1.x)) / (-s2_x * s1_y + s1_x * s2_y);
		if (s >= 0 && s <= 1 && t >= 0 && t <= 1)
		{
            return t;
        }
        return Math.POSITIVE_INFINITY;
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

        max = Math.min(max, lineVsLine(a1, a2, b1, b2, res));

        b1.x = hb.right;
        b1.y = hb.top;
        b2.x = hb.right;
        b2.y = hb.bottom;

        max = Math.min(max, lineVsLine(a1, a2, b1, b2, res));

        b1.x = hb.left;
        b1.y = hb.bottom;
        b2.x = hb.right;
        b2.y = hb.bottom;

        max = Math.min(max, lineVsLine(a1, a2, b1, b2, res));

        b1.x = hb.left;
        b1.y = hb.top;
        b2.x = hb.left;
        b2.y = hb.bottom;

        max = Math.min(max, lineVsLine(a1, a2, b1, b2, res));

        return max;
    }
}