extends Node2D
@onready var dialogue_label: Label = $chat
#onready var dialogue_timer: Timer = $chat_time
@onready var player = $PlayerMan2
@onready var timer = $Timer
@onready var end_notice= $end_of_round
@onready var sai=$sound_chuc_mung_sai
@onready var dung = $sound_chuc_mung_dung
@onready var dung_effect =$dung
@onready var sai_effect = $sai
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
var stylebox
var voice_cache = {}  # Dictionary preload toàn bộ âm thanh
var is_celebrating= false
var is_game_finished = false
func _ready():
	load_voice_assets()
	$Label.visible= false
	end_notice.visible= false
	stylebox = end_notice.get_theme_stylebox("normal") as StyleBoxFlat
	randomize()
	spawn_unique_mob()
	spawn_items()
	ans=randi_range(0,2)
	var loai = "mèo" if current_mob.scene_file_path == "res://man_2/cow.tscn" else "chó con"
	var food = " hộp pate" if current_mob.scene_file_path == "res://man_2/cow.tscn" else " cây xúc xích"
	chat = "Bé hãy cho chú " + loai + " ăn " + str(count[ans]) + food+" nhé."
	show_dialogue(chat)

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	thoat()
	print(round)
	if round > max_round:
		print('bbbbb')
		finish()
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
		var loai = "mèo" if current_mob.scene_file_path == "res://man_2/cow.tscn" else "chó con"
		var food = " hộp pate" if current_mob.scene_file_path == "res://man_2/cow.tscn" else " cây xúc xích"
		chat = "Bé hãy cho chú " + loai + " ăn " + str(count[ans]) + food+" nhé."
		show_dialogue(chat)
		player.turn= true
	if Input.is_action_just_pressed("ui_down") and player.position.y == 460:
		if nhat:
			remove_items_in_area()
			nhat=false
			if player.position== player.positions_ngang[ans]:
				check=true
func thoat():
	if Input.is_action_just_pressed("ui_thoat"):
		get_tree().change_scene_to_file("res://menu.tscn")
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
	var loai = "mèo" if current_mob.scene_file_path == "res://man_2/cow.tscn" else "chó con"
	var food = " hộp pate" if current_mob.scene_file_path == "res://man_2/cow.tscn" else " cây xúc xích"
	chat = "Bé hãy cho chú " + loai + " ăn " + str(count[ans]) + food+" nhé."
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
	await wait_until_not_celebrating()
	# >>> TÁCH CÂU THOẠI để đọc giọng nói <<<
	var loai = ""
	var do_an = ""
	var so_luong = 1

	if text.find("chó con") != -1:
		loai = "cho"
	else:
		loai = "meo"

	for i in range(1, 10):
		if str(i) in text:
			so_luong = i
			break

	if text.find("xúc xích") != -1:
		do_an = "xucxich"
	else:
		do_an = "pate"

	doc_chat(loai, so_luong, do_an)

# Hàm chúc mừng khi check = true
func chuc_mung():
	is_celebrating = true

	if check:
		if stylebox:
			stylebox.bg_color = Color(0, 1, 0, 1)
		end_notice.visible = true
		end_notice.text = "Chúc mừng bé! bé đã cho ăn xong rồi!"
		dung_effect.play()
		dung.play()
		check = false
		correct_answers += 1
	else:
		if stylebox:
			stylebox.bg_color = Color(1, 0, 0, 1)
		end_notice.visible = true
		end_notice.text = "Cố lên lần tới sẽ làm được"
		sai_effect.play()
		sai.play()

	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_tree().paused = false
	end_notice.visible = false

	is_celebrating = false

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
	is_game_finished = true
	stylebox.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	var result_text="📊 Tổng điểm:"+ str(correct_answers) +"\n"
	if correct_answers > max_round / 2:
		result_text += "Hoan hô! Bé thật giỏi!"
	else:
		result_text += "Không sao cả, bé hãy cố gắng lần sau nhé!"
	end_notice.text=result_text
	end_notice.visible=true
	$Label.visible =true
	if Input.is_action_just_pressed("ui_select") :
		get_tree().change_scene_to_file("res://menu.tscn")

func doc_chat(loai: String, so_luong: int, do_an: String) -> void:
	if loai == "cho":
		await play_voice("Bé-hãy-cho-chú-chó-con-ăn")
	else:
		await play_voice("Bé-hãy-cho-chú-mèo-con-ăn")

	await play_voice(str(so_luong))

	if do_an == "xucxich":
		await play_voice("Cây-xúc-xích-nhé")
	else:
		await play_voice("Hộp-pate-nhé")

func load_voice_assets():
	var folder_path = "res://man_2/assets/voice/"
	var filenames = [
		"Bé-hãy-cho-chú-chó-con-ăn", "Bé-hãy-cho-chú-mèo-con-ăn",
		"Hộp-pate-nhé", "Cây-xúc-xích-nhé"
	]

	# Thêm số từ 1–9
	for i in range(1, 10):
		filenames.append(str(i))

	# Load toàn bộ vào voice_cache
	for name in filenames:
		var path = folder_path + name + ".mp3"
		if ResourceLoader.exists(path):
			voice_cache[name] = load(path)
		else:
			push_error("❌ Không tìm thấy file voice: " + path)
func play_voice(file_name: String) -> void:
	if is_celebrating or round>max_round :
		return
	if not voice_cache.has(file_name):
		push_error("❌ Voice chưa preload: " + file_name)
		return

	var temp_player := AudioStreamPlayer.new()
	temp_player.stream = voice_cache[file_name]
	temp_player.volume_db = 15
	add_child(temp_player)
	temp_player.play()

	var duration = temp_player.stream.get_length()
	await get_tree().create_timer(duration).timeout

	temp_player.queue_free()
func wait_until_not_celebrating():
	while is_celebrating and not is_game_finished:
		await get_tree().process_frame
