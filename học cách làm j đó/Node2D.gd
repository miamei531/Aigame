extends Node2D

@export var letter_scene: PackedScene
@onready var target_label = $"../Targetletter"
@onready var diem =$"../diem"
@onready var screen_width = get_viewport_rect().size.x
var slots = [50, 150, 250, 350, 450] 
func _process(delta):
	if randf() < 0.005:
		spawn_letter()

func spawn_letter():
	var letter_instance = letter_scene.instantiate()
	var random_char = char(randi() % 3 + 97)  # 'a' to 'c'
	letter_instance.letter = random_char
	letter_instance.target_letter_label = target_label  # <-- Gán đúng label ở đây!
	letter_instance.diem_label = diem
	var random_x = slots.pick_random()
	letter_instance.position = Vector2(random_x, 0)
	add_child(letter_instance)
