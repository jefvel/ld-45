package states;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import entities.Player;
import entities.ProjectileCanvas;

class PlayState extends FlxState
{
	

	var ground:FlxSprite;
	var sky:FlxSprite;

	var player:Player;

	var projectileCanvas: ProjectileCanvas;
	var saloon: FlxSprite;

	function spawn() {
		player = new Player();
		player.setPosition(GameData.WorldWidth * 0.5, GameData.SkyLimit + 150);
		add(player);

		projectileCanvas = new ProjectileCanvas();
		add(projectileCanvas);
	}

	override public function create():Void
	{
		super.create();
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

			projectileCanvas.addShot(arm.x, arm.y, arm.x + v.x, arm.y + v.y);
		}
	}
}
