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

@onready var haitaosound = $Haitao
@onready var hoanosound = $Hoathucday
@onready var khen = $begioiqua

var clap_count := 0
var current_flower := 1
var current_apple := 0
var doing_flowers := true
var flower_round := 0

# khóa hành động
var action_done := false

# trạng thái kết thúc màn
var game_finished := false


func _ready():
	call_deferred("_start")
	nen.play()


func _start():
	await get_tree().create_timer(2).timeout
	player.move_to(flowersp[1].global_position)

	await get_tree().create_timer(1).timeout

	action_done = false

	if khen.playing:
		await khen.finished

	hoanosound.play()


func answer_correct():

	if current_flower >= flowers.size():
		return

	action_done = false
	player.move_to(flowersp[current_flower].global_position)
	current_flower += 3


func _process(delta):

	# nếu đã hoàn thành thì nhấn SPACE để thoát
	if game_finished and Input.is_action_just_pressed("ui_accept"):
		thoat()
		return

	if Input.is_action_just_pressed("ui_thoat"):
		thoat()

	if doing_flowers:
		if Input.is_action_just_pressed("ui_accept"):

			if player.moving or action_done:
				return

			action_done = true
			_handle_flower()

	else:
		if Input.is_action_just_pressed("ui_up"):

			if player.moving or action_done:
				return

			action_done = true
			player.play_jump()
			_handle_apple()


func thoat():
	print("Thoat scene")
	get_tree().change_scene_to_file("res://menu.tscn")


func _handle_flower():

	match flower_round:

		0:
			flowers[0].set_color(flowers[0].FlowerColor.RED)
			flowers[1].set_color(flowers[1].FlowerColor.BLUE)
			flowers[2].set_color(flowers[2].FlowerColor.YELLOW)

			await flowers[1].sprite.animation_finished

			khen.play()
			await khen.finished

			flower_round = 1
			doing_flowers = false

			player.move_to(applesp[0].global_position)

			await get_tree().create_timer(1).timeout

			if khen.playing:
				await khen.finished

			haitaosound.play()
			await haitaosound.finished

			action_done = false


		1:
			flowers[3].set_color(flowers[3].FlowerColor.BLUE)
			flowers[4].set_color(flowers[4].FlowerColor.YELLOW)
			flowers[5].set_color(flowers[5].FlowerColor.RED)

			await flowers[3].sprite.animation_finished

			khen.play()
			await khen.finished

			await get_tree().create_timer(1).timeout

			thongbao.visible = true
			game_finished = true

			print("Hoàn thành màn chơi")


func _handle_apple():

	var apple = apples[current_apple]

	var tween = create_tween()

	tween.tween_property(apple, "global_position", player.global_position, 0.4)
	tween.parallel().tween_property(apple, "scale", Vector2.ZERO, 0.4)

	await tween.finished

	apple.queue_free()

	khen.play()
	await khen.finished

	current_apple += 1

	if current_apple < apples.size():

		player.move_to(applesp[current_apple].global_position)

		await get_tree().create_timer(1).timeout

		if khen.playing:
			await khen.finished

		haitaosound.play()
		await haitaosound.finished

		action_done = false

	else:
		doing_flowers = true

		player.move_to(flowersp[4].global_position)

		await get_tree().create_timer(1).timeout

		if khen.playing:
			await khen.finished

		hoanosound.play()
		await hoanosound.finished

		action_done = false
