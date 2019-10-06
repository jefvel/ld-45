package states;

import GameData;
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

class PlayState extends FlxState
{
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
	var bloodSplashSound: FlxSound;

	var shadows: flixel.group.FlxGroup;

	var gibGroup: FlxGroup;
	var peopleGroup: flixel.group.FlxTypedGroup<FlxSprite>;

	var reloadTime = 0.0;

	var timeUntilNextWave = 0.0;

	var allBarrels: Array<Barrel>;
	var collectedBarrels: Array<Barrel>;

	var nextBarrelToDeposit: Barrel;

	var barrelDepositionQueue: Array<Barrel>;

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
		Enemy.shootableEntities.push(player.body);

		// Spawn civilians
		for (i in 0...5) {
			var civilian = new Civilian();
			var yPos = (Math.random() * FlxG.height);
			if (yPos < GameData.SkyLimit) {
				yPos += GameData.SkyLimit;
			}
			// if (Math.random() > 0.5) {
				civilian.setPosition(0, yPos);
			// } else {
			// 	civilian.setPosition(GameData.WorldWidth + civilian.width, yPos);
			// }
			peopleGroup.add(civilian);
			npcs.push(civilian);
			attachShadow(AssetPaths.shadow_small__png, civilian, 0, 53);
			Enemy.shootableEntities.push(civilian);
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

	function getXFarFromPlayer() {
		var x = Math.random() * GameData.WorldWidth;
		var playerX = player.x;
		while (Math.abs(x - playerX) < 500){
			x = Math.random() * GameData.WorldWidth;
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
		attachShadow(AssetPaths.shadow_small__png, enemy, 0, 53);
	}

	function attachShadow(shadowAsset: String, target: FlxSprite, offsetX: Float, offsetY: Float) {
		var shadow = new entities.Shadow(shadowAsset, offsetX, offsetY, target);
		shadows.add(shadow);
	}

	function removeShadow(target: FlxSprite) {
		for (e in shadows.iterator()) {
			if (cast(e, entities.Shadow).target == target) {
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

	override public function create():Void
	{
		super.create();
		ShotTools.NpcHitSignal.add(npcHitCallback);
		BloodExplosion.BloodHitGroundSignal.add(bloodHitGroundSignal);

		gunShotSound = FlxG.sound.load(AssetPaths.gunshot__ogg);
		crushSound = FlxG.sound.load(AssetPaths.death__ogg);

		impactSound = FlxG.sound.load(AssetPaths.impact__ogg);
		bloodSplashSound = FlxG.sound.load(AssetPaths.splash__ogg);

		npcs = [];
		
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
		
		shadows = new flixel.group.FlxGroup();
		add(shadows);

		saloon = new entities.Saloon();
		add(saloon);

		bloodCanvas = new BloodCanvas();
		add(bloodCanvas);

		gibGroup = new FlxGroup();
		add(gibGroup);

		spawn();
	}


	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
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
			
			var v = new flixel.math.FlxVector(mouseWorldPos.x - arm.x, mouseWorldPos.y - arm.y);
			v.normalize();
			v.scale(500);

			var tpos = new FlxPoint(gunPos.x + v.x, gunPos.y + v.y);

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
				nextBarrel.alpha -= elapsed * 4.0;
				if (nextBarrel.alpha <= 0) {
					barrelDepositionQueue.remove(nextBarrel);
					nextBarrel.destroy();
					if(barrelDepositionQueue.length > 0) {
						barrelDepositionQueue[0].following = saloon.door;
					}
				}
			}
		}

		peopleGroup.sort(FlxSort.byY, FlxSort.ASCENDING);
	}

	function npcHitCallback(target: entities.Person) {
		switch (target.personType) {
			case Player:
			case Enemy: 
				impactSound.play();
				target.hurt(GameData.GunDamage);
				if (!target.alive) {
					gibGroup.add(new entities.Gib(Enemy, target.x, target.y));
					spawnBarrel(target.x, target.y + 60);
				}
			case Citizen:
				target.hurt(GameData.GunDamage);
		}

		if (!target.alive) {
			crushSound.play();
			peopleGroup.remove(target, true);
			npcs.remove(target);
			removeShadow(target);
			Enemy.shootableEntities.remove(target);

			// Gore
			crushSound.play();
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

	function bloodHitGroundSignal(loc: FlxPoint) {
		// Gore
		bloodSplashSound.play();
		bloodCanvas.addBloodsplatter(loc.x, loc.y);
	}
}
