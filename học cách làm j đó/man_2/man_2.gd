extends Node2D
@onready var dialogue_label: Label = $chat
@onready var dialogue_timer: Timer = $chat_time
@onready var player = $PlayerMan2
@onready var timer = $Timer
@onready var end_notice= $end_of_round
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
func _ready():
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
	print("aaa",ans)
	if Input.is_action_just_pressed("ui_up") :	
		dem+=1
	print(dem)
	if dem >1 and player.position.distance_to(Vector2(536, 320)) < 2:
		timer.stop() 
		chuc_mung()
		timer.start()
		dem=0
		spawn_unique_mob()
		spawn_items()
		ans= randi_range(0,2)
		dialogue_label.visible = false
		var loai = "bò" if current_mob.scene_file_path == "res://man_2/cow.tscn" else "gà"
		var food = " bó rơm" if current_mob.scene_file_path == "res://man_2/cow.tscn" else " hạt thóc"
		chat = "Bé hãy cho con " + loai + " ăn " + str(count[ans]) + food+" nhé."
		show_dialogue(chat)
		player.turn= true
	if Input.is_action_just_pressed("ui_down") and player.position.y == 480:
		remove_items_in_area()
		if player.position== player.positions_ngang[ans]:
			check=true

func _on_timer_timeout():
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
	Vector2(196, 500), Vector2(216, 500), Vector2(236, 500),
	Vector2(196, 520), Vector2(216, 520), Vector2(236, 520),
	Vector2(196, 540), Vector2(216, 540), Vector2(236, 540)
]

var khu_2_positions = [
	Vector2(516, 500), Vector2(536, 500), Vector2(556, 500),
	Vector2(516, 520), Vector2(536, 520), Vector2(556, 520),
	Vector2(516, 540), Vector2(536, 540), Vector2(556, 540)
]

var khu_3_positions = [
	Vector2(836, 500), Vector2(856, 500), Vector2(876, 500),
	Vector2(836, 520), Vector2(856, 520), Vector2(876, 520),
	Vector2(836, 540), Vector2(856, 540), Vector2(876, 540)
]

var items_scenes = [
	preload("res://man_2/cow.tscn"),
	preload("res://man_2/chicken.tscn"),
]

# Spawn items
func spawn_items():
	var item_scene
	if current_mob.scene_file_path == "res://man_2/cow.tscn":
		item_scene = items_scenes[0]
	else:
		item_scene = items_scenes[1]

	var khu_vuc = [khu_1_positions, khu_2_positions, khu_3_positions]

	for khu in khu_vuc:
		var temp_positions = khu.duplicate()
		var item_count = randi_range(1, 9)
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
		end_notice.text=chuc_mung_text
		check = false

	else:
		end_notice.visible= true
		var chuc_mung_text = "Cố lên lần tới sẽ làm được"
		end_notice.text=chuc_mung_text
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	end_notice.visible=false

# Hàm xóa tất cả vật phẩm trong khu vực người chơi
func remove_items_in_area():
	var khu_vuc = get_player_area()  # Lấy khu vực mà người chơi đang đứng
	for item in spawned_items:
		if is_instance_valid(item) and item.position in khu_vuc:
			item.queue_free()  # Xóa vật phẩm
			spawned_items.erase(item)  # Loại bỏ vật phẩm khỏi danh sách

# Hàm trả về khu vực dựa trên vị trí của người chơi
func get_player_area():
	# Tùy vào vị trí người chơi, chọn khu vực thích hợp
	if player.position.x < 400:  # Khu 1
		return khu_1_positions
	elif player.position.x < 800:  # Khu 2
		return khu_2_positions
	else:  # Khu 3
		return khu_3_positions
