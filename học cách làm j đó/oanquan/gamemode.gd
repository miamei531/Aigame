extends Node2D
@onready var buttons: Array[Button] = [$Button, $Button2, $Button3]
@onready var khung= $"Kkkkk-removebg-preview"
var vitri=[Vector2(560,228),Vector2(560,432),Vector2(580,584)]
var size = [Vector2(1.312,0.528),Vector2(1.312,0.528),Vector2(0.398,0.144)]
var idx= 0
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DOWN:
			idx = (idx+4)%3
			khung.position=vitri[idx]
			khung.scale = size[idx]
		elif event.keycode == KEY_UP:
			idx = (idx+2)%3 
			khung.position=vitri[idx]
			khung.scale = size[idx]
		elif event.keycode == KEY_SPACE:      
			buttons[idx].emit_signal("pressed")
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://oanquan/dokho.tscn")    

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://oanquan/broad.tscn")

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
