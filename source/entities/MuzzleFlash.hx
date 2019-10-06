package entities;

import flixel.FlxSprite;
class MuzzleFlash extends FlxSprite {
    public function new() {
        super();
        loadGraphic(AssetPaths.muzzleflash__png, true, 32, 16, false);
        origin.set(0, 7);
        offset.set(0, 7);
        animation.add("s", [0, 1, 2, 3], 30, false);
        animation.play("s");
    }
    public override function update(elapsed: Float) {
        super.update(elapsed);
        if (this.animation.finished){
            destroy();
        }
    }
}