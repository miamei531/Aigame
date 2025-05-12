extends Node2D

func _ready():
	var mini_scene = preload("res://latvat/letter.tscn").instantiate()
	mini_scene.diem_label = $DiemLabel  # truyền Label từ scene chính vào
	add_child(mini_scene)
