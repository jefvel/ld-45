package;

import flixel.util.FlxTimer;

class Score {
    public static var HighScore = 0;
    public static var PlayerScore = 0;

    private static inline var EnemyKillPoints = 30;
    private static inline var CivilianKillPoints = -100;
    private static inline var TimePoints = 1;

    private var timePointTimer: FlxTimer;
    private static inline var timePointTickInterval = 1;

    public function new() {
        timePointTimer = new FlxTimer();
    }

    public function toggleTimeScore() {
        if (timePointTimer.active) {
            timePointTimer.cancel();
            timePointTimer.reset();
        } else {
            timePointTimer.start(
                1.0,
                addTimeTickPoints,
                0
            );
        }
    }

	public static function setPlayerHighScore() {
        if (Score.PlayerScore > Score.HighScore) {
            Score.HighScore = Score.PlayerScore;
        }
    }

    public static function addEnemyKill() {
        PlayerScore += EnemyKillPoints;
    }

    public static function addCivilianKill() {
        PlayerScore += CivilianKillPoints;
    }

    private static function addTimeTickPoints(timer:FlxTimer) {
        PlayerScore += TimePoints;
    }
}