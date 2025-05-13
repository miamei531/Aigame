extends Node2D

@export var letter_scene: PackedScene
@onready var target_label = $"../Targetletter"
@onready var diem = $"../diem"
@onready var screen_width = get_viewport_rect().size.x
var slots = [100, 300, 500, 700]  # Các vị trí nền tảng cố định

func _process(delta):
	if randf() < 0.005:  # Điều chỉnh tỷ lệ xuất hiện chữ cái
		spawn_letter()

func spawn_letter():
	var letter_instance = letter_scene.instantiate()
	var random_char = char(randi() % 3 + 97)  # 'a' đến 'c'
	letter_instance.letter = random_char
	letter_instance.target_letter_label = target_label
	letter_instance.diem_label = diem
	
	# Lấy một vị trí ngẫu nhiên từ các platform
	var random_x = slots.pick_random()  # Lấy ngẫu nhiên một giá trị x từ các vị trí đã xác định

	# Đảm bảo chữ cái bắt đầu từ trên cùng và rơi xuống
	letter_instance.position = Vector2(random_x, -50)  # Y = -50 sẽ đảm bảo nó bắt đầu từ trên

	# Thêm đối tượng vào scene
	add_child(letter_instance)
