extends Node2D


# Called when the node enters the scene tree for the first time.



func _on_pờ_lay_pressed():
	get_tree().change_scene_to_file("res://world.tscn")
	
func _ready():
	#Utils.savegame()
	Utils.loadgame()
