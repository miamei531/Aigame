extends Node

const save_path = "res://savegame.bin"
# Called when the node enters the scene tree for the first time.
func savegame():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	var data : Dictionary = {
		"playerHP": Game.playerHP,
		"gold": Game.gold,
	}
	var jstr =JSON.stringify(data)
	file.store_line(jstr)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func loadgame():
	var file = FileAccess.open(save_path, FileAccess.READ)
	if FileAccess.file_exists(save_path) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				Game.playerHP = current_line["playerHP"]
				Game.gold = current_line["gold"]
