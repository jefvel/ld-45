package entities;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class Saloon extends FlxSpriteGroup {
    public var door: FlxSprite;
    public var saloon: FlxSprite;
    public function new() {
        super();

        saloon = new FlxSprite();
		saloon.x = 120;
		saloon.y = GameData.SkyLimit - 220;
		saloon.loadGraphic(AssetPaths.saloon__png);
        add(saloon);

        door = new FlxSprite();
        door.x = 244;
        door.offset.x = -16;
        door.offset.y = -16;
        door.y = saloon.y + 187;
        door.makeGraphic(16, 16, flixel.util.FlxColor.TRANSPARENT);
        add(door);
    }
}