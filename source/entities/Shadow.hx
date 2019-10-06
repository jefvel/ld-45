package entities;

class Shadow extends flixel.FlxSprite {
    public var target: flixel.FlxSprite;
    public function new(shadowAsset: String, offsetX: Float, offsetY: Float, target: flixel.FlxSprite) {
        super();
        this.target = target;
        this.offset.set(-offsetX, -offsetY);
        this.loadGraphic(shadowAsset);
    }

    public override function update(elapsed: Float) {
        super.update(elapsed);
        this.x = target.x;
        this.y = target.y;
        if (!this.target.alive) {
            this.destroy();
        }
    }
}