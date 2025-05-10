extends Node2D


# Called when the node enters the scene tree for the first time.



func _on_pờ_lay_pressed():
	get_tree().change_scene_to_file("res://man_1.tscn")
	
func _ready():
	#Utils.savegame()
	Utils.loadgame()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://man_2/man_2.tscn")
