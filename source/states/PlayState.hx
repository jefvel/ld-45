package states;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;
import entities.Player;

class PlayState extends FlxState
{
	

	var ground:FlxSprite;
	var sky:FlxSprite;

	var player:Player;

	function spawn() {
		player = new Player();
		player.setPosition(GameData.SkyLimit, GameData.WorldWidth * 0.5);
		add(player);

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
		spawn();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (FlxG.mouse.justPressed) {
			var worldPos = FlxG.mouse.getWorldPosition();
			player.setMoveDest(worldPos.x, worldPos.y);
		}
	}
}
