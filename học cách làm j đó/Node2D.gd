extends Node2D

@export var letter_scene: PackedScene
@onready var target_label = $"../Targetletter"   # Label hiển thị chữ cái mục tiêu
@onready var diem = $"../diem"                   # Label hiển thị điểm
@onready var screen_width = get_viewport_rect().size.x

var slots = [100, 300, 500, 700]
var used_slots: Array = []

# Danh sách chữ cái tiếng Việt
var viet_letters = ['a', 'ă', 'â', 'b', 'c', 'd', 'a','a']

var min_letters_on_screen := 3   # Luôn có ít nhất 3 chữ
var spawn_interval := 0.9        # Chu kỳ spawn (giây)
var time_accumulator := 0.0

func _ready():
	# Random target letter ngay khi vào màn
	set_random_target_letter()
	diem.text = "0"

func _process(delta):
	time_accumulator += delta

	# Tạo chữ đều đặn
	if time_accumulator >= spawn_interval:
		time_accumulator -= spawn_interval
		spawn_letter()

	# Nếu ít chữ quá thì thêm vào
	if get_active_letters_count() < min_letters_on_screen:
		spawn_letter()

func spawn_letter():
	var letter_instance = letter_scene.instantiate()

	# Chọn ký tự tiếng Việt ngẫu nhiên cho chữ rơi
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

# Random chữ cái mục tiêu và hiển thị lên Label target_label
func set_random_target_letter():
	var random_char = viet_letters.pick_random()
	target_label.text = random_char
