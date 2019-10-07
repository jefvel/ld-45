package states;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxVector;
import openfl.display.Sprite;
import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxButton;
import entities.Person;
import js.html.ScreenOrientation;
import flixel.text.FlxText;
import flixel.util.FlxSignal;
import GameData;
import Score;
import states.MainMenuState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSort;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import entities.Player;
import entities.ProjectileCanvas;
import entities.BloodCanvas;
import entities.BloodExplosion;
import entities.Civilian;
import entities.ShotTools;
import entities.Enemy;
import entities.Barrel;
import entities.Shadow;

class PlayState extends FlxState
{
	var score:Score;
	var scoreDisplay:FlxText;

	var ground:FlxSprite;
	var sky:FlxSprite;

	var player:Player;

	var projectileCanvas: ProjectileCanvas;
	var bloodCanvas: BloodCanvas;
	var saloon: entities.Saloon;

	var gunShotSound: FlxSound;
	var crushSound: FlxSound;
	var impactSound: FlxSound;
	var pickupSound: FlxSound;
	var bloodSplashSound: FlxSound;
	var gameoverSound: FlxSound;
	var gamewinSound: FlxSound;

	var gameStartSound: FlxSound;

	var clongSound: FlxSound;

	var shadows: flixel.group.FlxTypedGroup<Shadow>;

	var gibGroup: FlxGroup;
	var peopleGroup: flixel.group.FlxTypedGroup<FlxSprite>;

	var reloadTime = 0.0;

	var timeUntilNextWave = 0.0;

	var allBarrels: Array<Barrel>;
	var collectedBarrels: Array<Barrel>;

	var nextBarrelToDeposit: Barrel;

	var barrelDepositionQueue: Array<Barrel>;

	var npcs: Array<entities.Person>;
	var enemies: Array<entities.Person>;
    var friendlies:Array<entities.Person>;

	var collectedBarrelCount = 0;
	var barrelsUntilNewCiv = 0;

	var victoryAchieved: Bool;

	// Victory UI
	var victoryGroup: FlxSpriteGroup;
	var victoryText: FlxText;
	var continueButton: FlxButton;

	// Death UI
	var deathGroup: FlxSpriteGroup;
	var deathText: FlxText;
	var retryButton: FlxButton;
	var mainMenuButton: FlxButton;

	var barrelArrow: FlxSprite;

	// var crossHair: FlxSprite;

	var progressBar: FlxSprite;
	var pBarHeight = 16.0;
	var indicator: FlxSprite;

	function spawn() {
		gameStartSound.play();
		FlxG.camera.setScrollBoundsRect(0, 0, GameData.WorldWidth, FlxG.stage.stageHeight, true);

		player = new Player();
		player.setPosition(200, GameData.SkyLimit + 150);

		collectedBarrels = [];
		allBarrels = [];
		barrelDepositionQueue = [];

		projectileCanvas = new ProjectileCanvas();
		add(projectileCanvas);

		peopleGroup = new flixel.group.FlxTypedGroup<FlxSprite>();
		add(peopleGroup);

		peopleGroup.add(player);
		camera.follow(player);
		camera.targetOffset.set(-32, -168);
		friendlies.push(player.body);

		barrelArrow = new FlxSprite();
		barrelArrow.loadGraphic(AssetPaths.arrow__png);
		barrelArrow.scrollFactor.set(0, 0);
		barrelArrow.y = GameData.SkyLimit - 200;
		barrelArrow.x = 50;

		add(barrelArrow);

		spawnEnemyWave();
	}

	function depositBarrels() {
		if (collectedBarrels.length > 0) {
			barrelDepositionQueue = barrelDepositionQueue.concat(collectedBarrels);
			for (i in 0...barrelDepositionQueue.length) {
				if (i == 0) {
					barrelDepositionQueue[i].following = saloon.door;
				} else {
					barrelDepositionQueue[i].following = barrelDepositionQueue[i - 1];
				}
			}

			collectedBarrels = [];
		}
	}

	function spawnBarrel(x, y) {
		var b = new Barrel();
		b.x = x;
		b.y = y;
		peopleGroup.add(b);
		allBarrels.push(b);
		return b;
	}

	function collectBarrel(b: Barrel) {
		if (collectedBarrels.length == 0) {
			b.following = player;
		} else {
			var prev = collectedBarrels[collectedBarrels.length - 1];
			b.following = prev;
		}

		allBarrels.remove(b);
		collectedBarrels.push(b);
	}

	var safeSpace = 450;
	function getXFarFromPlayer() {
		var x = Math.random() * (GameData.WorldWidth - safeSpace) + safeSpace;
		var playerX = player.x;
		while (Math.abs(x - playerX) < 400){
			x = Math.random() * (GameData.WorldWidth - safeSpace) + safeSpace;
		}

		return x;
	}

	function spawnEnemyWave() {
		// Spawn enemies
		// Do last so it can collect shootable entities in static class member
		for (i in 0...5) {
			var yPos = (Math.random() * FlxG.height);
			if (yPos < GameData.SkyLimit) {
				yPos += GameData.SkyLimit;
			}
			spawnEnemy(getXFarFromPlayer(), yPos);
		}

		timeUntilNextWave = GameData.EnemySpawnTime;
	}

	public function spawnEnemy(x, y) {
		if (enemies.length >= GameData.MaxEnemies) {
			return;
		}

		var enemy = new Enemy(friendlies);
		enemy.setPosition(x, y);
		peopleGroup.add(enemy);
		enemy.setProjectileCanvas(projectileCanvas);
		npcs.push(enemy);
		enemies.push(enemy);
		attachShadow(AssetPaths.shadow_small__png, enemy, 0, 53);
	}

	public function spawnCitizen(x, y) {
		var civ = new Civilian(enemies, projectileCanvas);
		civ.setPosition(x, y);
		peopleGroup.add(civ);
		npcs.push(civ);
		attachShadow(AssetPaths.shadow_small__png, civ, 0, 53);
		friendlies.push(civ);
	}

	function attachShadow(shadowAsset: String, target: FlxSprite, offsetX: Float, offsetY: Float) {
		var shadow = new entities.Shadow(shadowAsset, offsetX, offsetY, target);
		shadows.add(shadow);
	}

	function removeShadow(target: FlxSprite) {
		for (e in shadows) {
			if (e.target == target) {
				shadows.remove(e);
				return;
			}
		}
	}

	var bgDetails: flixel.group.FlxTypedGroup<FlxSprite>;
	inline static var RockAmount = 60;
	function createRocksAndStuff() {
		bgDetails = new flixel.group.FlxTypedGroup<FlxSprite>();

		// Clouds
		for (i in 0...20) {
			var r = new FlxSprite(
				Math.random() * GameData.WorldWidth,
				Math.random() * GameData.SkyLimit * 0.5
			);
			r.loadGraphic(AssetPaths.clouds__png, true, 64, 32);
			r.animation.randomFrame();
			r.scrollFactor.x = 0.1 + Math.random() * 0.2;
			bgDetails.add(r);
		}

		// Border between ground and sky
		var dx = Std.int(Math.ceil(GameData.WorldWidth / 64));
		for (i in 0...dx) {
			var r = new FlxSprite(
				i * 64,
				GameData.SkyLimit - 6
			);
			r.loadGraphic(AssetPaths.groundedges__png, true, 64, 8);
			r.animation.randomFrame();
			bgDetails.add(r);
		}

		var exitSign = new FlxSprite();
		exitSign.loadGraphic(AssetPaths.exitsign__png);
		exitSign.x = GameData.WorldWidth - 30 - exitSign.width;
		exitSign.offset.y = 45;
		exitSign.y = GameData.SkyLimit;
		bgDetails.add(exitSign);

		// Ground details (rocks, plants etc)
		for (i in 0...RockAmount) {
			var r = new FlxSprite(
				Math.random() * GameData.WorldWidth,
				GameData.SkyLimit + Math.random() * GameData.GroundHeight
			);
			r.loadGraphic(AssetPaths.rocks__png, true, 16, 16);
			r.animation.randomFrame();
			bgDetails.add(r);
		}
		add(bgDetails);

		bgDetails.sort(FlxSort.byY, FlxSort.ASCENDING);
	}

	function buyCitizen() {
		barrelsUntilNewCiv = GameData.CivCost;
		spawnCitizen(saloon.door.x, saloon.door.y + 30);
	}

	override public function create():Void
	{
		super.create();
		FlxG.camera.zoom = 2;

		FlxG.timeScale = 1.0;

		victoryAchieved = false;

		ShotTools.NpcHitSignal = new FlxTypedSignal<entities.Person->Void>();
		ShotTools.NpcHitSignal.add(npcHitCallback);

		BloodExplosion.BloodHitGroundSignal = new FlxTypedSignal<FlxPoint->Void>();
		BloodExplosion.BloodHitGroundSignal.add(bloodHitGroundSignal);

		gunShotSound = FlxG.sound.load(AssetPaths.gunshot__ogg);
		crushSound = FlxG.sound.load(AssetPaths.death__ogg);

		impactSound = FlxG.sound.load(AssetPaths.impact__ogg);
		bloodSplashSound = FlxG.sound.load(AssetPaths.splash__ogg);

		pickupSound = FlxG.sound.load(AssetPaths.pickup__ogg);
		gameoverSound = FlxG.sound.load(AssetPaths.gameover__ogg);
		gamewinSound = FlxG.sound.load(AssetPaths.gamewin__ogg);
		clongSound = FlxG.sound.load(AssetPaths.clong__ogg);

		gameStartSound = FlxG.sound.load(AssetPaths.gamestart__ogg);

		npcs = [];
		enemies = [];
		friendlies = [];

		barrelsUntilNewCiv = GameData.CivCost;

		sky = new FlxSprite();
		sky.makeGraphic(FlxG.width, GameData.SkyLimit, 0xff41ade9);
		add(sky);
		sky.scrollFactor.set(0, 1.0);

		ground = new FlxSprite();
		ground.makeGraphic(FlxG.width, GameData.GroundHeight, 0xffe8b796);
		ground.y = GameData.SkyLimit;
		add(ground);
		ground.scrollFactor.set(0, 1.0);

		createRocksAndStuff();

		shadows = new flixel.group.FlxTypedGroup<Shadow>();
		add(shadows);

		saloon = new entities.Saloon();
		add(saloon);

		bloodCanvas = new BloodCanvas();
		add(bloodCanvas);

		gibGroup = new FlxGroup();
		add(gibGroup);


		spawn();
/*
		crossHair = new FlxSprite();
		crossHair.loadGraphic(AssetPaths.crosshair__png);
		crossHair.offset.set(16, 16);
		crossHair.scrollFactor.set(0, 0);
		add(crossHair);
		crossHair.visible = false;
*/
		createUI();
	}

	function createUI() {
		score = new Score();
		scoreDisplay = new FlxText(
			FlxG.width * 0.05,
			FlxG.height * 0.05,
			0,
			"0",
			32
		);
		scoreDisplay.scrollFactor.set(0, 0);
		scoreDisplay.color = 0xFF9E2835;
		add(scoreDisplay);
		scoreDisplay.visible = false;
		score.toggleTimeScore();

		// Death UI
		deathGroup = new FlxSpriteGroup();
		deathGroup.scrollFactor.set(0, 0);

		deathText = new FlxText(0, FlxG.height * 0.25, FlxG.width, "D E A D", 64);

		deathText.alignment = FlxTextAlign.CENTER;
		deathText.color = 0xFF9E2835;
		deathGroup.add(deathText);

		var buttonYP = 0.8;

		retryButton = new FlxButton(FlxG.width * 0.3, FlxG.height * buttonYP, "Retry", restartGame);
		retryButton.setSize(Math.floor(FlxG.width * 0.2), Math.floor(FlxG.height * 0.1));
		retryButton.setGraphicSize(cast retryButton.width, cast retryButton.height);
		deathGroup.add(retryButton);

		mainMenuButton = new FlxButton(FlxG.width * 0.55, FlxG.height * buttonYP, "Main Menu", exitGame);
		mainMenuButton.setSize(Math.floor(FlxG.width * 0.2), Math.floor(FlxG.height * 0.1));
		mainMenuButton.setGraphicSize(cast mainMenuButton.width, cast mainMenuButton.height);
		deathGroup.add(mainMenuButton);

		// victory UI
		victoryGroup = new FlxSpriteGroup();
		victoryGroup.scrollFactor.set(0, 0);

		victoryText = new FlxText(0, FlxG.height * 0.15, FlxG.width, "V I C T O R Y", 52);
		victoryText.alignment = FlxTextAlign.CENTER;
		victoryText.color = 0xFF265C42;
		victoryGroup.add(victoryText);

		continueButton = new FlxButton(FlxG.width * 0.6, FlxG.height * buttonYP, "Exit", exitGame);
		continueButton.setSize(Math.floor(FlxG.width * 0.2), Math.floor(FlxG.height * 0.1));
		continueButton.setGraphicSize(cast continueButton.width, cast continueButton.height);
		victoryGroup.add(continueButton);

		progressBar = new FlxSprite();
		progressBar.loadGraphic(AssetPaths.progressbar__png);
		add(progressBar);
		progressBar.offset.y = 32;
		progressBar.x = (FlxG.width - progressBar.width) * 0.5;
		progressBar.y = progressBar.x;
		progressBar.scrollFactor.set(0, 0);

		indicator = new FlxSprite();
		indicator.loadGraphic(AssetPaths.progressbarindicator__png);
		indicator.offset.set(indicator.width * 0.5, indicator.height * 0.5);
		add(indicator);
		indicator.y = progressBar.y + pBarHeight * 0.5 - 10;
		indicator.x = progressBar.x + pBarHeight;
		indicator.scrollFactor.set(0, 0);

	}

	function barrelDeposited(b: Barrel) {
		collectedBarrelCount++;
		barrelsUntilNewCiv --;
		if (barrelsUntilNewCiv <= 0) {
			buyCitizen();
		}
		barrelDepositionQueue.remove(b);
		pickupSound.play();
		b.destroy();
		if(barrelDepositionQueue.length > 0) {
			barrelDepositionQueue[0].following = saloon.door;
		}
	}

	var time = 0.0;
	var lastMouseX = 0.0;
	var lastMouseY = 0.0;
	var curMouseX = 0.0;
	var curMouseY = 0.0;

	var firstMoveDone = false;

	function gameupdate(elapsed: Float) {
		var progress = 0.0;
		var bestCitizen = null;
		for (e in friendlies) {
			if (e.personType == Player) {
				continue;
			}

			if(bestCitizen == null) {
				bestCitizen = e;
				continue;
			}

			if (e.x > bestCitizen.x) {
				bestCitizen = e;
			}
		}

		if (bestCitizen != null && bestCitizen.x > 0) {
			progress = bestCitizen.x / GameData.VictoryBoundaryX;
			progress = Math.min(1.0, progress);
		}

		var pw = progressBar.width - pBarHeight;
		pw *= progress;
		var targetX = progressBar.x + pBarHeight * 0.5 + pw;
		indicator.drag.x = 90;
		indicator.velocity.x = (targetX - indicator.x);

		var sp = saloon.getScreenPosition();
		barrelArrow.visible = collectedBarrels.length > 0;
		barrelArrow.y = GameData.SkyLimit - 120;
		barrelArrow.x = Math.max(20, sp.x + saloon.width + barrelArrow.width);
		barrelArrow.x += Math.sin(time) * 10;

		timeUntilNextWave -= elapsed;
		if (timeUntilNextWave < 0) {
			spawnEnemyWave();
		}

		reloadTime -= elapsed;

		var mouseWorldPos = FlxG.mouse.getWorldPosition();
		var arm = player.arm;

		// Virtual joystick control
		/*
		if (FlxG.mouse.justPressed) {
			var sp = arm.getScreenPosition();
			lastMouseX = sp.x;
			lastMouseY = sp.y;
			curMouseX = FlxG.mouse.screenX;
			curMouseY = FlxG.mouse.screenY;
			crossHair.x = curMouseX;
			crossHair.y = curMouseY;
			firstMoveDone = false;
		}

		crossHair.visible = FlxG.mouse.pressed;

		if (FlxG.mouse.pressed && FlxG.mouse.justMoved) {
			if (!firstMoveDone) {
				firstMoveDone = true;
				var s = crossHair.getScreenPosition();
				lastMouseX = s.x;
				lastMouseY = s.y;
			}
			var v = FlxVector.get(curMouseX - FlxG.mouse.screenX, curMouseY - FlxG.mouse.screenY);
			//lastMouseX = curMouseX;
			//lastMouseY = curMouseY;
			curMouseX = FlxG.mouse.screenX;
			curMouseY = FlxG.mouse.screenY;
		}
		*/

		if (FlxG.mouse.pressed && reloadTime <= 0) {
			reloadTime = GameData.ReloadTime;
			var arm = player.arm;
			player.shoot(mouseWorldPos.x, mouseWorldPos.y);
			var gunPos = arm.getMuzzleWorldPos();

			var v = flixel.math.FlxVector.get(mouseWorldPos.x - arm.x, mouseWorldPos.y - arm.y);
			//var v = flixel.math.FlxVector.get(curMouseX - lastMouseX, curMouseY - lastMouseY);
			v.normalize();
			v.scale(500);


			var tpos = FlxPoint.get(gunPos.x + v.x, gunPos.y + v.y);

			var target: entities.Person = null;
			var d = Math.POSITIVE_INFINITY;
			for (npc in npcs) {
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

			// White line bullet thing
			projectileCanvas.addShot(gunPos.x, gunPos.y, tpos.x, tpos.y);

			// Add muzzle flash
			var mf = new entities.MuzzleFlash();
			mf.angle = arm.angle;
			mf.x = gunPos.x;
			mf.y = gunPos.y;
			add(mf);
		}

		for (b in allBarrels) {
			if (FlxG.overlap(b, player)) {
				collectBarrel(b);
			}
		}

		if (FlxG.overlap(player, saloon)) {
			depositBarrels();
		}

		if (barrelDepositionQueue.length > 0) {
			var nextBarrel = barrelDepositionQueue[0];
			if (FlxG.overlap(nextBarrel, saloon.door)) {
				nextBarrel.alpha -= elapsed * 5.0;
				if (nextBarrel.alpha <= 0) {
					barrelDeposited(nextBarrel);
				}
			}
		}

		// Check victory condition
		for (e in npcs) {
			if (e.personType == PersonType.Citizen && e.x > GameData.VictoryBoundaryX) {
				winGame();
			}
		}
	}

	function winGame() {
		displayVictoryScreen();
		Score.setPlayerHighScore();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		time += elapsed;

		if (player.body.alive && !victoryAchieved) {
			gameupdate(elapsed);
		}

		peopleGroup.sort(FlxSort.byY, FlxSort.ASCENDING);

		// Update score
		scoreDisplay.text = "" + Score.PlayerScore;
		scoreDisplay.color = Score.PlayerScore < 0 ? 0xFF9E2835 : 0xFF193C3E;
	}

	function displayDeathScreen() {
		if (!victoryAchieved) {
			gameoverSound.play(true);
			// Animate thing
			deathText.y = FlxG.height * 0.25;
			deathText.alpha = 0.0;
			var t = new FlxTimer();
			t.start(0.4, function(t) {
				deathText.alpha = 1.0;
				deathText.y = FlxG.height * 0.2;
				clongSound.play();
			});

			retryButton.alpha = 0.0;
			FlxTween.tween(retryButton, {
				alpha: 1.0,
			}, 0.2, { ease: FlxEase.backOut, startDelay: 0.45 });

			mainMenuButton.alpha = 0.0;
			FlxTween.tween(mainMenuButton, {
				alpha: 1.0,
			}, 0.2, { ease: FlxEase.backOut, startDelay: 0.5 });

			// scoreDisplay.visible = !scoreDisplay.visible;
			add(deathGroup);
		}
	}

	function displayVictoryScreen() {

		victoryAchieved = true;
		gamewinSound.play();
		for (civ in friendlies) {
			if(civ.personType == Citizen) {
				var c = cast(civ, Civilian);
				c.startCheering();
			}
		}

		var winMan = new entities.WinMan();
		winMan.x = FlxG.width * 0.3;
		winMan.y = FlxG.height + winMan.height;

		var winArm = new entities.WinArm();
		winArm.x = FlxG.width * 0.5;
		winArm.y = FlxG.height + winArm.height;

		FlxTween.tween(winArm, {
			y: FlxG.height,
		}, 0.4, { ease: FlxEase.backOut, startDelay: 4.6 });

		FlxTween.tween(winMan, {
			y: FlxG.height,
		}, 0.6, { ease: FlxEase.backOut, startDelay: 4.63 });

		victoryGroup.add(winMan);
		victoryGroup.add(winArm);

		victoryGroup.add(continueButton);


		victoryText.alpha = 0.0;
		victoryText.y = FlxG.height * 0.1;
		FlxTween.tween(victoryText, {
			alpha: 1.0,
			y: FlxG.height * 0.15,
		}, 0.5, { ease: FlxEase.backOut, startDelay: 4.65 });

/*
		var newHighScoreSet = Score.PlayerScore > Score.HighScore;
		if (newHighScoreSet) {
			var newHighScoreSetDisplay = new FlxText(
				0,
				FlxG.height * 0.5,
				FlxG.width,
				"You set a new highscore!",
				24
			);
			newHighScoreSetDisplay.alignment = FlxTextAlign.CENTER;
			newHighScoreSetDisplay.color = 0xFF164C32;
			victoryGroup.add(newHighScoreSetDisplay);
		}

		var oldHighScoreDisplay = new FlxText(
			0,
			FlxG.height * 0.6,
			FlxG.width,
			"Current highscore: " + Score.HighScore,
			16
		);
		oldHighScoreDisplay.alignment = FlxTextAlign.CENTER;
		oldHighScoreDisplay.color = 0xFF164C32;
		victoryGroup.add(oldHighScoreDisplay);

		var yourScoreDisplay = new FlxText(
			0,
			FlxG.height * 0.7,
			FlxG.width,
			newHighScoreSet ? "New highscore: " + Score.PlayerScore : "Your score: " + Score.PlayerScore,
			16
		);
		yourScoreDisplay.alignment = FlxTextAlign.CENTER;
		yourScoreDisplay.color = 0xFF164C32;
		victoryGroup.add(yourScoreDisplay);
		*/

		add(victoryGroup);
	}

	function npcHitCallback(target: entities.Person) {
		switch (target.personType) {
			case Player:
				if (!victoryAchieved) {
					target.hurt(GameData.GunDamage);
				}
				if (!target.alive) {
					FlxG.timeScale = 0.2;
					gibGroup.add(new entities.Gib(Player, target.x - 20, target.y - 50));
					displayDeathScreen();
				}
			case Enemy:
				impactSound.play();
				target.hurt(GameData.GunDamage);
				if (!target.alive) {
					gibGroup.add(new entities.Gib(Enemy, target.x, target.y));
					Score.addEnemyKill();
					spawnBarrel(target.x, target.y + 60);
					enemies.remove(target);
				}
			case Citizen:
				if (!victoryAchieved) {
					target.hurt(GameData.GunDamage);
				}
				if (!target.alive) {
					Score.addCivilianKill();
					gibGroup.add(new entities.Gib(Citizen, target.x, target.y));
				}
		}

		if (!target.alive) {
			crushSound.play();
			peopleGroup.remove(target, true);
			npcs.remove(target);
			removeShadow(target);
			friendlies.remove(target);

			// Gore
			crushSound.play();
			if (target != null && target.offset != null) {
				var gore = new BloodExplosion(
					target.x + target.offset.x,
					target.y + target.offset.y
				);
				gore.setSize(
					target.width * 0.2,
					target.height * 0.2
				);
				gore.start(true);
				add(gore);
				bloodCanvas.addBloodsplatter(target.x, target.y);
			}
		}
	}

	function restartGame() {
		score.toggleTimeScore();
		Score.PlayerScore = 0;

		FlxG.resetState();
	}

	function exitGame() {
		score.toggleTimeScore();
		Score.PlayerScore = 0;

		FlxG.switchState(new MainMenuState());
	}

	function bloodHitGroundSignal(loc: FlxPoint) {
		// Gore
		bloodSplashSound.play();
		bloodCanvas.addBloodsplatter(loc.x, loc.y);
	}
}
