extends Node2D

@onready var dialogue_label: Label = $chat
@onready var dialogue_timer: Timer = $chat_time
@onready var player = $PlayerMan2
@onready var timer = $Timer
@onready var end_notice = $end_of_round
@onready var sound_chuc_mung_dung = $sound_chuc_mung_dung
@onready var sound_chuc_mung_sai = $sound_chuc_mung_sai

var mob_scenes = [
	preload("res://man_2/cow.tscn"),
	preload("res://man_2/chicken.tscn"),
]
var items_scenes = [
	preload("res://man_2/rom.tscn"),
	preload("res://man_2/HAT.tscn"),
]

var count = [0, 0, 0]
var current_mob: Node = null
var spawned_items = []
var count_index = 0
var chat = ""
var dem = 0
var check = false
var ans
var nhat = true
#<<<<<<< HEAD
#=======

#func _ready():
	#end_notice.visible= false
	#randomize()
	#spawn_unique_mob()
	#spawn_items()
	#ans=randi_range(0,2)
	#var loai = "bò" if current_mob.scene_file_path == "res://man_2/cow.tscn" else "gà"
	#var food = " bó rơm" if current_mob.scene_file_path == "res://man_2/cow.tscn" else " hạt thóc"
	#chat = "Bé hãy cho con " + loai + " ăn " + str(count[ans]) + food+" nhé."
	#show_dialogue(chat)
#>>>>>>> c7bc414d30f8268795f70b2d55d1e4ab107a226d

var total_rounds = 10
var current_round = 1
var correct_count = 0

var khu_1_positions = [
	Vector2(166, 490), Vector2(216, 490), Vector2(266, 490),
	Vector2(166, 545), Vector2(216, 545), Vector2(266, 545),
	Vector2(166, 600), Vector2(216, 600), Vector2(266, 600)
]
var khu_2_positions = [
	Vector2(486, 490), Vector2(536, 490), Vector2(586, 490),
	Vector2(486, 545), Vector2(536, 545), Vector2(586, 545),
	Vector2(486, 600), Vector2(536, 600), Vector2(586, 600)
]
var khu_3_positions = [
	Vector2(806, 490), Vector2(856, 490), Vector2(906, 490),
	Vector2(806, 545), Vector2(856, 545), Vector2(906, 545),
	Vector2(806, 600), Vector2(856, 600), Vector2(906, 600)
]

func _ready():
	end_notice.visible = false
	randomize()
	start_new_round()

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		dem += 1

	if dem > 1 and player.position.distance_to(Vector2(536, 320)) < 2:
		timer.stop()
		chuc_mung()
		timer.start()
		dem = 0
		nhat = true
		if current_round <= total_rounds:
			start_new_round()
		else:
			show_final_result()
		player.turn = true

	if Input.is_action_just_pressed("ui_down") and player.position.y == 460:
		if nhat:
			remove_items_in_area()
			nhat = false
			if player.position == player.positions_ngang[ans]:
				check = true

func _on_timer_timeout():
	nhat = true
	chuc_mung()
	dem = 0
	player.position = Vector2(536, 320)
	player.current_index = 0
	player.check = 0
	player.turn = true
	if current_round <= total_rounds:
		start_new_round()
	else:
		show_final_result()

func start_new_round():
	count = [0, 0, 0]
	count_index = 0
	check = false
	clear_spawned_items()
	spawn_unique_mob()
	spawn_items()
	ans = randi_range(0, 2)
	var loai = "bò" if current_mob.scene_file_path == "res://man_2/cow.tscn" else "gà"
	var food = " bó rơm" if current_mob.scene_file_path == "res://man_2/cow.tscn" else " hạt thóc"
	chat = "Bé hãy cho con " + loai + " ăn " + str(count[ans]) + food + " nhé."
	show_dialogue(chat)

func spawn_unique_mob():
	if current_mob and is_instance_valid(current_mob):
		current_mob.queue_free()
	var mob_scene = mob_scenes[randi() % mob_scenes.size()]
	current_mob = mob_scene.instantiate()
	current_mob.position = Vector2(800, 280)
	add_child(current_mob)

func spawn_items():
	var item_scene = items_scenes[0] if current_mob.scene_file_path == "res://man_2/cow.tscn" else items_scenes[1]
	var khu_vuc = [khu_1_positions, khu_2_positions, khu_3_positions]
	var a = [1, 2, 3, 4, 5, 6, 7, 8, 9]
	for khu in khu_vuc:
		var temp_positions = khu.duplicate()
		var idx = randi() % a.size()
		var item_count = a[idx]
		a.remove_at(idx)
		count[count_index] = item_count
		count_index += 1
		for i in range(item_count):
			if temp_positions.is_empty():
				break
			var index = randi() % temp_positions.size()
			var pos = temp_positions[index]
			temp_positions.remove_at(index)
			var item = item_scene.instantiate()
			add_child(item)
			item.position = pos
			spawned_items.append(item)

func clear_spawned_items():
	for item in spawned_items:
		if is_instance_valid(item):
			item.queue_free()
	spawned_items.clear()

func show_dialogue(text: String):
	dialogue_label.text = text
	dialogue_label.visible = true

func chuc_mung():
	if check:
		sound_chuc_mung_dung.play()
	else:
		sound_chuc_mung_sai.play()

	if check:
		correct_count += 1
		end_notice.text = "Chúc mừng bé! bé đã cho ăn xong rồi!"
	else:
		end_notice.text = "Cố lên lần tới sẽ làm được"

	end_notice.visible = true
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	end_notice.visible = false
	current_round += 1
	check = false

func remove_items_in_area():
	var khu_vuc = get_player_area()
	for item in spawned_items.duplicate():
		if is_instance_valid(item) and item.position in khu_vuc:
			item.queue_free()
			spawned_items.erase(item)

func get_player_area():
	if player.position.x < 400:
		return khu_1_positions
	elif player.position.x < 800:
		return khu_2_positions
	else:
		return khu_3_positions

func show_final_result():
	dialogue_label.visible = true
	dialogue_label.text = "Trò chơi kết thúc! Bé đã hoàn thành đúng " + str(correct_count) + " / " + str(total_rounds) + " hiệp."
	end_notice.visible = true
	end_notice.text = "Cảm ơn bé đã chơi! Nhấn ESC để thoát."
	get_tree().paused = true
