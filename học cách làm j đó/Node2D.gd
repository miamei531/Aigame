extends Node2D

@export var letter_scene: PackedScene
@onready var target_label = $"../Targetletter"
@onready var diem = $"../diem"
@onready var screen_width = get_viewport_rect().size.x
var slots = [100, 300, 500, 700]
var used_slots: Array = []

var viet_letters = ['a', 'ă', 'â', 'b', 'c', 'd', 'a','a'
					 ]

var min_letters_on_screen := 3  # Luôn đảm bảo có ít nhất 3 chữ đang rơi
var spawn_interval := 0.9  # Tạo chữ mới mỗi 0.6s để tránh spam
var time_accumulator := 0.0

func _process(delta):
	time_accumulator += delta

	# Tạo chữ đều đặn
	if time_accumulator >= spawn_interval:
		time_accumulator -= spawn_interval
		spawn_letter()

	# Nếu số lượng chữ trên màn hình quá ít, thêm vào để không bị trống
	if get_active_letters_count() < min_letters_on_screen:
		spawn_letter()

func spawn_letter():
	var letter_instance = letter_scene.instantiate()

	# Chọn ký tự tiếng Việt ngẫu nhiên
	var random_char = viet_letters.pick_random()
	letter_instance.letter = random_char
	letter_instance.target_letter_label = target_label
	letter_instance.diem_label = diem

	# Tránh spawn trùng vị trí
	var available_slots = slots.filter(func(x): return not used_slots.has(x))
	if available_slots.is_empty():
		used_slots.clear()
		available_slots = slots.duplicate()

	var random_x = available_slots.pick_random()
	used_slots.append(random_x)

	# Spawn từ trên đỉnh rơi xuống
	letter_instance.position = Vector2(random_x, -50)
	add_child(letter_instance)

func get_active_letters_count() -> int:
	var count := 0
	for child in get_children():
		if "letter" in child:
			count += 1
	return count
