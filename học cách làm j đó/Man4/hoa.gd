extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var pivot: Node2D = $"."


enum FlowerColor {
	NONE,
	RED,
	BLUE,
	YELLOW
}

var current_color = FlowerColor.NONE


func _ready():
	sprite.play("grey")


func set_color(color: FlowerColor):

	current_color = color

	match color:
		FlowerColor.RED:
			sprite.play("red")

		FlowerColor.BLUE:
			sprite.play("blue")

		FlowerColor.YELLOW:
			sprite.play("yellow")
		
		FlowerColor.NONE:
			sprite.play("NONE")
