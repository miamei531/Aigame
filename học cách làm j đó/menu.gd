extends Node2D

@onready var bgms = $AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	up_date_music_start()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://man_1.tscn")
func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://man_2/man_2.tscn")


func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://lv/man3.tscn")
func up_date_music_start():
	if !bgms.playing:
		bgms.play()
		print("nhạc chạy")
