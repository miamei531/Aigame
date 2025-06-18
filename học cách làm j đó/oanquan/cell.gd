extends Node2D

@export var cell_index: int = 0
#signal cell_pressed(index: int)

func _ready():
	$Area2D.input_event.connect(_on_area_input)

func _on_area_input(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("cell_pressed", cell_index)
