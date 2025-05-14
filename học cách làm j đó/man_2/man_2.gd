extends Node2D


var mob_scenes = [
	preload("res://man_2/cow.tscn"),
	preload("res://man_2/chicken.tscn"),
]

var current_mob: Node = null  # Mob hiện tại (duy nhất)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	spawn_unique_mob()
# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_timer_timeout():
	spawn_unique_mob()
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
