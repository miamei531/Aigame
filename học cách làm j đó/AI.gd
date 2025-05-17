extends Node

func _ready():
	var exe_path := ""

	if OS.has_feature("editor"):
		# Khi chạy trong Godot Editor
		exe_path = ProjectSettings.globalize_path("res://bin/myGame.exe")
	else:
		# Khi đã export game: lấy đường dẫn chứa .exe chính
		var game_dir = OS.get_executable_path().get_base_dir()
		exe_path = game_dir.path_join("bin").path_join("myGame.exe")
	
	print("Gọi exe tại:", exe_path)

	# Chạy process độc lập, không block game
	var error = OS.create_process(exe_path, [])
	if error != OK:
		print("❌ Lỗi khi chạy process: ", error)
	else:
		print("✅ Chạy AI .exe thành công!")
