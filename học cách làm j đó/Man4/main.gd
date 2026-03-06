extends Node2D
@onready var player = $CharacterBody2D
@onready var nen = $nen
@onready var flowersp = [
	$Flower1/TargetPosition,
	$Flower2/TargetPosition,
	$Flower3/TargetPosition
]
@onready var flowers = [
	$Flower1,
	$Flower2,
	$Flower3
]
@onready var applesp = [
	$Apple1/TargetPosition,
	$Apple2/TargetPosition,
	$Apple3/TargetPosition
]
@onready var apples = [
	$Apple1,
	$Apple2,
	$Apple3
]
var clap_count := 0
var current_flower := 0
var current_apple := 0
var doing_flowers := true
func _ready():
	call_deferred("_start")

func _start():
	player.move_to(flowersp[0].global_position)
func answer_correct():
	
	if current_flower >= flowers.size():
		return

	player.move_to(flowersp[current_flower].global_position)

	current_flower += 1
func _process(delta):
	if doing_flowers:
		if Input.is_action_just_pressed("ui_accept"):
			if player.moving:
				return
			_handle_flower()
	else:
		if Input.is_action_just_pressed("ui_up"):
			if player.moving:
				return
			player.play_jump()
			_handle_apple()
func _handle_flower():
	match current_flower:
		0: flowers[0].set_color(flowers[0].FlowerColor.RED)
		1: flowers[1].set_color(flowers[1].FlowerColor.BLUE)
		2: flowers[2].set_color(flowers[2].FlowerColor.YELLOW)
	
	current_flower += 1
	
	if current_flower < flowers.size():
		player.move_to(flowersp[current_flower].global_position)
	else:
		doing_flowers = false
		player.move_to(applesp[0].global_position)

func _handle_apple():
	apples[current_apple].drop()
	
	current_apple += 1
	
	if current_apple < apples.size():
		player.move_to(applesp[current_apple].global_position)
