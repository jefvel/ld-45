package states;

import GameData;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import entities.Player;
import entities.ProjectileCanvas;
import entities.BloodCanvas;
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

	var npcs: Array<FlxSprite>;

	var gunShotSound: FlxSound;
	var crushSound: FlxSound;
	var shadows: flixel.group.FlxGroup;

	function spawn() {
		FlxG.camera.setScrollBoundsRect(0, 0, GameData.WorldWidth, FlxG.stage.stageHeight, true);
		player = new Player();
		player.setPosition(GameData.WorldWidth * 0.5, GameData.SkyLimit + 150);
		add(player);
		camera.follow(player);
		camera.targetOffset.set(-32, -168);
		Enemy.shootableEntities.push(player.arm);

		bloodCanvas = new BloodCanvas();
		add(bloodCanvas);
		
		projectileCanvas = new ProjectileCanvas();
		add(projectileCanvas);

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
			add(civilian);
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
			add(enemy);
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

	var rocks: FlxGroup;
	inline static var RockAmount = 60;
	function createRocksAndStuff() {
		rocks = new FlxGroup();
		for (i in 0...RockAmount) {
			var r = new FlxSprite(
				Math.random() * GameData.WorldWidth, 
				GameData.SkyLimit + Math.random() * GameData.GroundHeight
			);
			r.loadGraphic(AssetPaths.rocks__png, true, 16, 16);
			r.animation.randomFrame();
			rocks.add(r);
		}
		add(rocks);
	}

	override public function create():Void
	{
		super.create();
		ShotTools.NpcHitSignal.add(npcHitCallback);


		gunShotSound = FlxG.sound.load(AssetPaths.gunshot__ogg);
		crushSound = FlxG.sound.load(AssetPaths.death__ogg);

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
		saloon.y = GameData.SkyLimit - 240;
		saloon.loadGraphic(AssetPaths.saloon__png);
		add(saloon);

		spawn();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed) {
			var worldPos = FlxG.mouse.getWorldPosition();
			var arm = player.arm;
			player.shoot(worldPos.x, worldPos.y);
			var v = new flixel.math.FlxVector(worldPos.x - arm.x, worldPos.y - arm.y);
			v.normalize();
			v.scale(500);

			var gunPos = new FlxPoint(arm.x, arm.y);

			var tpos = new FlxPoint(arm.x + v.x, arm.y + v.y);

			var target: FlxSprite = null;
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
		}
	}

	function npcHitCallback(target: FlxSprite) {
		crushSound.play();
		bloodCanvas.addBloodsplatter(target.x, target.y);
		remove(target);
		npcs.remove(target);
		removeShadow(target);
		Enemy.shootableEntities.remove(target);
	}
}
