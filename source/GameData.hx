package;
import flixel.FlxG;

class GameData {
    public static var SkyLimit:Int = 269;
    public static var WorldWidth:Int = 480 * 4;
    public static var GroundHeight:Int = 680 - SkyLimit;
    public static var WorldHeight: Int = GroundHeight + SkyLimit;

    public static inline var ReloadTime = 0.2;

    public static inline var EnemySpawnTime = 5.0;

    public static inline var GunDamage = 10.0;

    public static inline var EnemyGunRange = 300.0;
    public static inline var EnemyHealth = 20.0;
    public static inline var EnemyAimTime = 1.6;
    public static inline var EnemyReloadTime = 1.7;
    public static inline var EnemyHurtRecoveryTime = 0.2;

    public static inline var CivHealth = 25.0;
    public static inline var CivCost = 4;
    public static inline var CivReloadTime = 3.0;
    public static inline var CivGunRange = 250.0;

    public static var HighScore = 0;
}