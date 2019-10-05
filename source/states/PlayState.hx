package states;

import GameData;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxPoint;
import entities.Player;
import entities.ProjectileCanvas;
import entities.Civilian;
import entities.ShotTools;

class PlayState extends FlxState
{
	

	var ground:FlxSprite;
	var sky:FlxSprite;

	var player:Player;

	var projectileCanvas: ProjectileCanvas;
	var saloon: FlxSprite;

	var npcs: Array<FlxSprite>;

	function spawn() {
		player = new Player();
		player.setPosition(GameData.WorldWidth * 0.5, GameData.SkyLimit + 150);
		add(player);

		projectileCanvas = new ProjectileCanvas();
		add(projectileCanvas);

		// Spawn civilians
		for (i in 0...10) {
			var civilian = new Civilian();
			var yPos = (Math.random() * FlxG.height);
			if (yPos < GameData.SkyLimit) {
				yPos += GameData.SkyLimit;
			}
			if (Math.random() > 0.5) {
				civilian.setPosition(0, yPos);
			} else {
				civilian.setPosition(GameData.WorldWidth + civilian.width, yPos);
			}
			add(civilian);
			civilian.setNewDest();
			npcs.push(civilian);
		}
	}

	override public function create():Void
	{
		super.create();
		npcs = [];
		ground = new FlxSprite();
		ground.makeGraphic(FlxG.width, FlxG.height, 0xffe8b796);
		add(ground);
		
		sky = new FlxSprite();
		sky.makeGraphic(FlxG.width, GameData.SkyLimit, 0xff41ade9);
		add(sky);

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
				v.normalize();
				remove(target);
				npcs.remove(target);
				v.scale(d);
				tpos.x = gunPos.x + v.x;
				tpos.y = gunPos.y + v.y;
			}

			projectileCanvas.addShot(gunPos.x, gunPos.y, tpos.x, tpos.y);
		}
	}
}
