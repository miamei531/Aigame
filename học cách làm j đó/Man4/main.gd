extends Node2D

@onready var player = $CharacterBody2D
@onready var nen = $nen
@onready var thongbao = $Label
@onready var flowersp = [
	$Flower1/TargetPosition,
	$Flower2/TargetPosition,
	$Flower3/TargetPosition,
	$Flower6/TargetPosition,
	$Flower5/TargetPosition,
	$Flower4/TargetPosition
]

@onready var flowers = [
	$Flower1,
	$Flower2,
	$Flower3,
	$Flower6,
	$Flower5,
	$Flower4,
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
var current_flower := 1
var current_apple := 0
var doing_flowers := true

# thêm biến này
var flower_round := 0

func _ready():
	call_deferred("_start")

func _start():
	await get_tree().create_timer(2).timeout
	player.move_to(flowersp[1].global_position)


func answer_correct():

	if current_flower >= flowers.size():
		return

	player.move_to(flowersp[current_flower].global_position)
	current_flower += 3


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

	match flower_round:

		0:
			flowers[0].set_color(flowers[0].FlowerColor.RED)
			flowers[1].set_color(flowers[1].FlowerColor.BLUE)
			flowers[2].set_color(flowers[2].FlowerColor.YELLOW)

			await flowers[1].sprite.animation_finished

			flower_round = 1
			doing_flowers = false
			player.move_to(applesp[0].global_position)


		1:
			flowers[3].set_color(flowers[3].FlowerColor.BLUE)
			flowers[4].set_color(flowers[4].FlowerColor.YELLOW)
			flowers[5].set_color(flowers[5].FlowerColor.RED)
			
			await flowers[3].sprite.animation_finished
			await get_tree().create_timer(5).timeout
			thongbao.visible = true
			print("Hoàn thành màn chơi")


func _handle_apple():

	var apple = apples[current_apple]

	var tween = create_tween()

	tween.tween_property(apple, "global_position", player.global_position, 0.4)
	tween.parallel().tween_property(apple, "scale", Vector2.ZERO, 0.4)

	await tween.finished

	apple.queue_free()

	current_apple += 1

	if current_apple < apples.size():
		player.move_to(applesp[current_apple].global_position)

	else:
		doing_flowers = true
		player.move_to(flowersp[4].global_position)
