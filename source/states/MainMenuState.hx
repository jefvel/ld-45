package states;

import flixel.input.mouse.FlxMouseEventManager;
import flixel.FlxState;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.text.FlxText;


class MainMenuState extends FlxState
{
	public var titleText: FlxText;
	public var infoText: FlxText;
	public var playBtn: FlxButton;

	override public function create():Void
	{
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
				Bandits are at it by Cool Saloon again.
				Go deliver 'em some cold-served justice.
				Your ol' horse Nothing is a stubborn beast.
				Only the recoil of your gun will get her moving.
				But watch out!
				The saloon gets very busy during the day so take care
				not to shoot the locals when making the horse move!
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
