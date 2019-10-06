package states;

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

	var npcs: Array<entities.Person>;

	var gunShotSound: FlxSound;
	var crushSound: FlxSound;
	var impactSound: FlxSound;
	var pickupSound: FlxSound;
	var bloodSplashSound: FlxSound;

	var shadows: flixel.group.FlxTypedGroup<Shadow>;

	var gibGroup: FlxGroup;
	var peopleGroup: flixel.group.FlxTypedGroup<FlxSprite>;

	var reloadTime = 0.0;

	var timeUntilNextWave = 0.0;

	var allBarrels: Array<Barrel>;
	var collectedBarrels: Array<Barrel>;

	var nextBarrelToDeposit: Barrel;

	var barrelDepositionQueue: Array<Barrel>;

	var collectedBarrelCount = 0;
	var barrelsUntilNewCiv = 0;

	var victoryAchieved: Bool;

	// Victory UI
	var victoryGroup: FlxSpriteGroup;
	var victoryText: FlxText;
	var continueButton: FlxButton;
	var enemies: Array<entities.Person>;

	// Death UI
	var deathGroup: FlxSpriteGroup;
	var deathText: FlxText;
	var retryButton: FlxButton;
	var mainMenuButton: FlxButton;

	function spawn() {
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
		entities.Enemy.shootableEntities.push(player.body);

		// Spawn civilians
		for (i in 0...5) {
			/*
			var civilian = new Civilian();
			var yPos = (Math.random() * FlxG.height);
			if (yPos < GameData.SkyLimit) {
				yPos += GameData.SkyLimit;
			}
			*/
			// if (Math.random() > 0.5) {
			spawnCitizen(saloon.door.x, saloon.door.y + 30);
			// } else {
			// 	civilian.setPosition(GameData.WorldWidth + civilian.width, yPos);
			// }
		}
		
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
		var enemy = new Enemy();
		enemy.setPosition(x, y);
		peopleGroup.add(enemy);
		enemy.setProjectileCanvas(projectileCanvas);
		npcs.push(enemy);
		enemies.push(enemy);
		attachShadow(AssetPaths.shadow_small__png, enemy, 0, 53);
	}

	public function spawnCitizen(x, y) {
		var civ = new Civilian(enemies);
		civ.setPosition(x, y);
		peopleGroup.add(civ);
		npcs.push(civ);
		attachShadow(AssetPaths.shadow_small__png, civ, 0, 53);
		entities.Enemy.shootableEntities.push(civ);
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

		npcs = [];
		enemies = [];

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
		score.toggleTimeScore();

		// Death UI
		deathGroup = new FlxSpriteGroup();
		deathGroup.scrollFactor.set(0, 0);

		deathText = new FlxText(0, FlxG.height * 0.3, FlxG.width, "D E A D", 64);
		deathText.alignment = FlxTextAlign.CENTER;
		deathText.color = 0xFF9E2835;
		deathGroup.add(deathText);

		retryButton = new FlxButton(FlxG.width * 0.3, FlxG.height * 0.5, "Retry", restartGame);
		retryButton.setSize(Math.floor(FlxG.width * 0.2), Math.floor(FlxG.height * 0.1));
		retryButton.setGraphicSize(cast retryButton.width, cast retryButton.height);
		deathGroup.add(retryButton);
		
		mainMenuButton = new FlxButton(FlxG.width * 0.55, FlxG.height * 0.5, "Exit", exitGame);
		mainMenuButton.setSize(Math.floor(FlxG.width * 0.2), Math.floor(FlxG.height * 0.1));
		mainMenuButton.setGraphicSize(cast mainMenuButton.width, cast mainMenuButton.height);
		deathGroup.add(mainMenuButton);

		// victory UI
		victoryGroup = new FlxSpriteGroup();
		victoryGroup.scrollFactor.set(0, 0);

		victoryText = new FlxText(0, FlxG.height * 0.3, FlxG.width, "V I C T O R Y", 64);
		victoryText.alignment = FlxTextAlign.CENTER;
		victoryText.color = 0xFF9E2835;
		victoryGroup.add(victoryText);
		
		continueButton = new FlxButton(FlxG.width * 0.45, FlxG.height * 0.8, "Exit", exitGame);
		continueButton.setSize(Math.floor(FlxG.width * 0.2), Math.floor(FlxG.height * 0.1));
		continueButton.setGraphicSize(cast continueButton.width, cast continueButton.height);
		victoryGroup.add(continueButton);

		spawn();
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

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!player.body.alive || victoryAchieved)
			return;

		timeUntilNextWave -= elapsed;
		if (timeUntilNextWave < 0) {
			spawnEnemyWave();
		}

		reloadTime -= elapsed;
		
		var mouseWorldPos = FlxG.mouse.getWorldPosition();

		if (FlxG.mouse.justPressedMiddle) {
			spawnEnemy(mouseWorldPos.x, mouseWorldPos.y);
		}

		if (FlxG.mouse.pressed && reloadTime <= 0) {
			reloadTime = GameData.ReloadTime;
			var arm = player.arm;
			player.shoot(mouseWorldPos.x, mouseWorldPos.y);
			var gunPos = arm.getMuzzleWorldPos();
			
			var v = flixel.math.FlxVector.get(mouseWorldPos.x - arm.x, mouseWorldPos.y - arm.y);
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

			projectileCanvas.addShot(gunPos.x, gunPos.y, tpos.x, tpos.y);
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

		peopleGroup.sort(FlxSort.byY, FlxSort.ASCENDING);

		// Update score
		scoreDisplay.text = "" + Score.PlayerScore;
		scoreDisplay.color = Score.PlayerScore < 0 ? 0xFF9E2835 : 0xFF193C3E;

		// Check victory condition
		for (e in npcs) {
			if (e.personType == PersonType.Citizen && e.x > GameData.VictoryBoundaryX) {
				victoryAchieved = true;
				displayVictoryScreen();
				Score.setPlayerHighScore();
			}
		}
	}

	function displayDeathScreen() {
		scoreDisplay.visible = !scoreDisplay.visible;
		add(deathGroup);
	}

	function displayVictoryScreen() {
		scoreDisplay.visible = !scoreDisplay.visible;

		var newHighScoreSet = Score.PlayerScore > Score.HighScore;
		if (newHighScoreSet) {
			var newHighScoreSetDisplay = new FlxText(
				FlxG.width * 0.35,
				0,
				FlxG.width,
				"You set a new highscore!",
				24
			);
			newHighScoreSetDisplay.alignment = FlxTextAlign.CENTER;
			victoryGroup.add(newHighScoreSetDisplay);
		}

		var oldHighScoreDisplay = new FlxText(
			FlxG.width * 0.4,
			0.45,
			FlxG.width,
			"Current highscore:" + Score.HighScore,
			16
		);
		oldHighScoreDisplay.alignment = FlxTextAlign.CENTER;
		victoryGroup.add(oldHighScoreDisplay);

		var yourScoreDisplay = new FlxText(
			FlxG.width * 0.4,
			0.45,
			FlxG.width,
			newHighScoreSet ? "New highscore:" : "Your score:" + Score.HighScore,
			16
		);
		yourScoreDisplay.alignment = FlxTextAlign.CENTER;
		victoryGroup.add(yourScoreDisplay);

		add(victoryGroup);
	}

	function npcHitCallback(target: entities.Person) {
		switch (target.personType) {
			case Player:
				target.hurt(GameData.GunDamage);
				if (!target.alive) {
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
				target.hurt(GameData.GunDamage);
				if (!target.alive) {
					Score.addCivilianKill();
				}
		}

		if (!target.alive) {
			crushSound.play();
			peopleGroup.remove(target, true);
			npcs.remove(target);
			removeShadow(target);
			entities.Enemy.shootableEntities.remove(target);

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
