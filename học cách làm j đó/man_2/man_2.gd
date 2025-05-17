extends Node2D
@onready var dialogue_label: Label = $chat
@onready var dialogue_timer: Timer = $chat_time
@onready var player = $PlayerMan2
@onready var timer = $Timer
@onready var end_notice= $end_of_round
@onready var sai=$sound_chuc_mung_sai
@onready var dung = $sound_chuc_mung_dung
var round = 0           # Đếm số hiệp hiện tại (bắt đầu từ 1)
var max_round = 3       # Tổng số hiệp muốn chơi (giới hạn là 10)
var correct_answers = 0  # Đếm số câu bé làm đúng
var mob_scenes = [
	preload("res://man_2/cow.tscn"),
	preload("res://man_2/chicken.tscn"),
]
var count = [0,0,0]
var current_mob: Node = null  # Mob hiện tại (duy nhất)
var spawned_items = []  # Lưu danh sách các item đã spawn
var count_index= 0
# Called when the node enters the scene tree for the first time.
var chat=""
var dem=0
var check = false
var ans
var nhat = true
func _ready():
	$Button.visible = false
	end_notice.visible= false
	randomize()
	spawn_unique_mob()
	spawn_items()
	ans=randi_range(0,2)
	var loai = "bò" if current_mob.scene_file_path == "res://man_2/cow.tscn" else "gà"
	var food = " bó rơm" if current_mob.scene_file_path == "res://man_2/cow.tscn" else " hạt thóc"
	chat = "Bé hãy cho con " + loai + " ăn " + str(count[ans]) + food+" nhé."
	show_dialogue(chat)

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	print(round)
	if round > max_round:
		print('bbbbb')
		finish()
		get_tree().paused=true
	print("aaa",ans)
	if Input.is_action_just_pressed("ui_up") :	
		dem+=1
	print(dem)
	if dem >1 and player.position.distance_to(Vector2(536, 320)) < 2:
		timer.stop() 
		chuc_mung()
		timer.start()
		dem=0
		nhat= true
		spawn_unique_mob()
		spawn_items()
		ans= randi_range(0,2)
		dialogue_label.visible = false
		var loai = "bò" if current_mob.scene_file_path == "res://man_2/cow.tscn" else "gà"
		var food = " bó rơm" if current_mob.scene_file_path == "res://man_2/cow.tscn" else " hạt thóc"
		chat = "Bé hãy cho con " + loai + " ăn " + str(count[ans]) + food+" nhé."
		show_dialogue(chat)
		player.turn= true
	if Input.is_action_just_pressed("ui_down") and player.position.y == 460:
		if nhat:
			remove_items_in_area()
			nhat=false
			if player.position== player.positions_ngang[ans]:
				check=true

func _on_timer_timeout():
	player.check=0
	player.current_index=0
	nhat = true
	chuc_mung()
	dem=0
	player.position = Vector2(536, 320)
	player.turn = true
	spawn_unique_mob()
	spawn_items()
	ans=randi_range(0,2)
	dialogue_label.visible = false
	var loai = "bò" if current_mob.scene_file_path == "res://man_2/cow.tscn" else "gà"
	var food = " bó rơm" if current_mob.scene_file_path == "res://man_2/cow.tscn" else " hạt thóc"
	chat = "Bé hãy cho con " + loai + " ăn " + str(count[ans]) + food+" nhé."
	show_dialogue(chat)
	
# Spawn mob duy nhất
func spawn_unique_mob():
	round+=1
	# Xoá mob cũ nếu còn tồn tại
	if current_mob and is_instance_valid(current_mob):
		current_mob.queue_free()
	# Random mob mới
	var mob_scene = mob_scenes[randi() % mob_scenes.size()]
	var mob = mob_scene.instantiate()
	# Đặt vị trí mob
	mob.position = Vector2(800, 280)
	add_child(mob)
	current_mob = mob
	# Xoá tất cả các item đã spawn
	clear_spawned_items()

# Mỗi khu chứa 9 vị trí
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
var items_scenes = [
	preload("res://man_2/rom.tscn"),
	preload("res://man_2/HAT.tscn"),
]
# Spawn items
func spawn_items():
	var item_scene
	if current_mob.scene_file_path == "res://man_2/cow.tscn":
		item_scene = items_scenes[0]
	else:
		item_scene = items_scenes[1]
	var khu_vuc = [khu_1_positions, khu_2_positions, khu_3_positions]
	var a=[1,2,3,4,5,6,7,8,9]
	for khu in khu_vuc:
		var temp_positions = khu.duplicate()
		var idx=randi() % a.size()
		var item_count = a[idx]
		a.remove_at(idx)
		count[count_index]= item_count
		count_index +=1
		for i in range(item_count):
			if temp_positions.is_empty():
				break
			var index = randi() % temp_positions.size()
			var pos = temp_positions[index]
			temp_positions.remove_at(index)
			# Spawn item
			var item = item_scene.instantiate()
			add_child(item)
			item.position = pos
			# Lưu item vào danh sách spawned_items để xóa sau
			spawned_items.append(item)
# Xóa tất cả item đã spawn
func clear_spawned_items():
	# Duyệt qua tất cả item đã spawn và xóa chúng
	for item in spawned_items:
		if is_instance_valid(item):
			item.queue_free()
	# Làm rỗng danh sách spawned_items
	spawned_items.clear()
	count_index= 0
func show_dialogue(text: String):
	dialogue_label.text = text
	dialogue_label.visible = true
# Hàm chúc mừng khi check = true
func chuc_mung():
	# Hiển thị thông báo chúc mừng
	if check:
		end_notice.visible= true
		var chuc_mung_text = "Chúc mừng bé! bé đã cho ăn xong rồi!"
		dung.play()
		end_notice.text=chuc_mung_text
		check = false
		correct_answers +=1
	else:
		end_notice.visible= true
		var chuc_mung_text = "Cố lên lần tới sẽ làm được"
		$Button.visible = true
		sai.play()
		end_notice.text=chuc_mung_text
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	end_notice.visible=false
# Hàm xóa tất cả vật phẩm trong khu vực người chơi
func remove_items_in_area():
	var khu_vuc = get_player_area()
	for item in spawned_items.duplicate():
		if is_instance_valid(item) and item.position in khu_vuc:
			item.queue_free()
			spawned_items.erase(item)
func get_player_area():
	# Tùy vào vị trí người chơi, chọn khu vực thích hợp
	if player.position.x < 400:  # Khu 1
		return khu_1_positions
	elif player.position.x < 800:  # Khu 2
		return khu_2_positions
	else:  # Khu 3
		return khu_3_positions
func finish():
	var result_text="📊 Tổng điểm:"+ str(correct_answers) +"\n"
	if correct_answers > max_round / 2:
		result_text += "Hoan hô! Bé thật giỏi!"
	else:
		result_text += "Không sao cả, bé hãy cố gắng lần sau nhé!"
	end_notice.text=result_text
	end_notice.visible=true
	if Input.is_action_just_pressed("ui_select"):
		get_tree().change_scene_to_file("res://menu.tscn")
