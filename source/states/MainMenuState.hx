package states;

import flixel.input.mouse.FlxMouseEventManager;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSort;
import entities.Horse;

class MainMenuState extends FlxState
{
	public var skyLimit: Int;
	
	public var titleText: FlxText;
	public var infoText: FlxText;
	public var playBtn: FlxButton;

	var bgDetails: flixel.group.FlxTypedGroup<FlxSprite>;
	inline static var RockAmount = 10;
	function createRocksAndStuff() {
		bgDetails = new flixel.group.FlxTypedGroup<FlxSprite>();

		// Border between ground and sky
		var dx = Std.int(Math.ceil(FlxG.width / 64));
		for (i in 0...dx) {
			var r = new FlxSprite(
				i * 64,
				skyLimit - 6
			);
			r.loadGraphic(AssetPaths.groundedges__png, true, 64, 8);
			r.animation.randomFrame();
			bgDetails.add(r);
		}

		// Ground details (rocks, plants etc)
		for (i in 0...RockAmount) {
			var r = new FlxSprite(
				Math.random() * FlxG.width, 
				skyLimit + Math.random() * GameData.GroundHeight
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
		skyLimit = Math.floor(GameData.SkyLimit * 1.7);

		// Scenery
		var sky = new FlxSprite();
		sky.makeGraphic(FlxG.width, skyLimit, 0xff41ade9);
		add(sky);

		var ground = new FlxSprite();
		ground.makeGraphic(FlxG.width, GameData.GroundHeight, 0xffe8b796);
		ground.y = skyLimit;
		add(ground);

		createRocksAndStuff();

		var horseGroup = new FlxSpriteGroup();

        var horse = new Horse();
        horseGroup.add(horse);

        var leg1 = new FlxSprite(null, null, AssetPaths.horseleg__png);
        leg1.offset.set(5, 1);
        leg1.origin.set(5, 1);
        horseGroup.add(leg1);

		horseGroup.x = FlxG.width * 0.5;
        horseGroup.y = skyLimit - 25;
		add(horseGroup);

		// UI

		titleText = new flixel.text.FlxText(
			0,
			32,
			FlxG.width,
			"Howdy Sheriff!",
			32
		);
		titleText.alignment = FlxTextAlign.CENTER;

		infoText = new flixel.text.FlxText(
			0,
			FlxG.height * 0.2,
			FlxG.width - 32,
			"
				Bandits are at it by The Cool Saloon again.
				Go deliver 'em some cold-served justice.
				Your ol' horse Nothing is a stubborn beast.
				Only the recoil of your gun will get her moving.

				The locals will join arms in exchange for bandit liquor,
				but try not to shoot them when making the horse move!
			",
			12
		);
		infoText.alignment = FlxTextAlign.CENTER;
		
		playBtn = new FlxButton(FlxG.width * 0.4, FlxG.height * 0.8, "Get some!", onClickPlay);
		playBtn.setSize(Math.floor(FlxG.width * 0.3), Math.floor(FlxG.height * 0.1));
		playBtn.setGraphicSize(cast playBtn.width, cast playBtn.height);

		super.create();
		add(titleText);
		add(infoText);
		add(playBtn);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	static private function onClickPlay() {
		FlxG.switchState(new PlayState());
	}
}
