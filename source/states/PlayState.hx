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

class PlayState extends FlxState
{
	var ground:FlxSprite;
	var sky:FlxSprite;

	var player:Player;

	var projectileCanvas: ProjectileCanvas;
	var bloodCanvas: BloodCanvas;
	var saloon: FlxSprite;

	var npcs: Array<entities.Person>;

	var gunShotSound: FlxSound;
	var crushSound: FlxSound;
	var bloodSplashSound: FlxSound;
	var shadows: flixel.group.FlxGroup;

	var gibGroup: FlxGroup;
	var peopleGroup: flixel.group.FlxTypedGroup<FlxSprite>;

	function spawn() {
		FlxG.camera.setScrollBoundsRect(0, 0, GameData.WorldWidth, FlxG.stage.stageHeight, true);
		player = new Player();
		player.setPosition(200, GameData.SkyLimit + 150);
		
		projectileCanvas = new ProjectileCanvas();
		add(projectileCanvas);

		peopleGroup = new flixel.group.FlxTypedGroup<FlxSprite>();
		add(peopleGroup);

		peopleGroup.add(player);
		camera.follow(player);
		camera.targetOffset.set(-32, -168);
		Enemy.shootableEntities.push(player.body);

		bloodCanvas = new BloodCanvas();
		add(bloodCanvas);

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
		
		// Spawn enemies 
		// Do last so it can collect shootable entities in static class member
		for (i in 0...5) {
			var enemy = new Enemy();
			var yPos = (Math.random() * FlxG.height);
			if (yPos < GameData.SkyLimit) {
				yPos += GameData.SkyLimit;
			}
			// if (Math.random() > 0.5) {
			// 	enemy.setPosition(0, yPos);
			// } else {
				enemy.setPosition(GameData.WorldWidth + enemy.width, yPos);
			// }
			peopleGroup.add(enemy);
			enemy.setProjectileCanvas(projectileCanvas);
			npcs.push(enemy);
			attachShadow(AssetPaths.shadow_small__png, enemy, 0, 53);
		}
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

		saloon = new FlxSprite();
		saloon.x = 120;
		saloon.y = GameData.SkyLimit - 220;
		saloon.loadGraphic(AssetPaths.saloon__png);
		add(saloon);

		gibGroup = new FlxGroup();
		add(gibGroup);

		spawn();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed) {
			var worldPos = FlxG.mouse.getWorldPosition();
			var arm = player.arm;
			player.shoot(worldPos.x, worldPos.y);
			var gunPos = arm.getMuzzleWorldPos();
			
			var v = new flixel.math.FlxVector(worldPos.x - arm.x, worldPos.y - arm.y);
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
				gunShotSound.stop();
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
		peopleGroup.sort(FlxSort.byY, FlxSort.ASCENDING);
	}

	function npcHitCallback(target: entities.Person) {
		peopleGroup.remove(target, true);

		switch (target.personType) {
			case Player:
			case Enemy: 
				target.kill();
				gibGroup.add(new entities.Gib(Enemy, target.x, target.y));
			case Citizen:
				target.kill();
		}
		
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
		
		// Remove entity
		remove(target);
		npcs.remove(target);
		removeShadow(target);
		Enemy.shootableEntities.remove(target);
	}

	function bloodHitGroundSignal(loc: FlxPoint) {
		// Gore
		bloodSplashSound.play();
		bloodCanvas.addBloodsplatter(loc.x, loc.y);
	}
}
