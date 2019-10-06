package entities;

enum PersonType {
    Enemy;
    Citizen;
    Player;
}

class Person extends flixel.FlxSprite {
    public var personType: PersonType;
}