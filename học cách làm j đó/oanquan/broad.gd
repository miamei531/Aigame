extends Node2D

# === 1. HẰNG SỐ VÀ BIẾN TOÀN CỤC ===
const CELL_SCENE := preload("res://oanquan/cell.tscn")

var cells: Array[int] = [0, 5, 5, 5, 5, 5, 0, 5, 5, 5, 5, 5]
var cell_nodes: Array[Node] = []
var selected_index := 0
var current_player := 1
var waiting_for_direction := false

# === 2. KHỞI TẠO BÀN CHƠI ===
func _ready():
	for i in range(12):
		var cell = CELL_SCENE.instantiate()
		cell.cell_index = i  # Giữ đúng chỉ số logic

		# Vị trí hiển thị: ô 0–5 ở hàng trên trái→phải, ô 6–11 ở hàng dưới phải→trái
		var x = i % 6
		var y = int(i / 6)
		var display_index = i
		if i >= 6:
			display_index = 11 - i + 6  # Đảo ngược thứ tự ô ở hàng dưới

		cell.position = Vector2(80 + (display_index % 6) * 70, 200 + y * 100)
		add_child(cell)
		cell_nodes.append(cell)
		_update_cell_label(cell, i)
	_highlight_selected()

# === 3. XỬ LÝ INPUT BÀN PHÍM ===
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if not waiting_for_direction:
			if current_player == 2:
				if event.keycode == KEY_D:
					_move_selection(-1)
				elif event.keycode == KEY_A:
					_move_selection(1)
				elif event.keycode == KEY_S:
					if _is_valid_move(selected_index):
						waiting_for_direction = true
			elif current_player == 1:
				if event.keycode == KEY_LEFT:
					_move_selection(-1)
				elif event.keycode == KEY_RIGHT:
					_move_selection(1)
				elif event.keycode == KEY_DOWN:
					if _is_valid_move(selected_index):
						waiting_for_direction = true
		else:
			if(event.keycode == KEY_UP or event.keycode == KEY_W):
				waiting_for_direction = false
			elif (event.keycode == KEY_D and current_player == 2) or (event.keycode == KEY_LEFT and current_player == 1):
				_play_turn(selected_index, false)
				waiting_for_direction = false
			elif (event.keycode == KEY_A and current_player == 2) or (event.keycode == KEY_RIGHT and current_player == 1):
				_play_turn(selected_index, true)
				waiting_for_direction = false

# === 4. XỬ LÝ DI CHUYỂN CON TRỎ CHỌN Ô ===
func _move_selection(offset: int):
	for _i in range(12):
		selected_index = (selected_index + offset + 12) % 12
		if _is_valid_move(selected_index):
			break
	_highlight_selected()

# === 5. CHƠI MỘT LƯỢT ===
func _play_turn(index: int, clockwise: bool):
	var num = cells[index]
	cells[index] = 0
	var idx = index
	while true:
		while num > 0:
			idx = (idx + (1 if clockwise else -1) + 12) % 12
			cells[idx] += 1
			num -= 1
		idx=(idx + (1 if clockwise else -1) + 12) % 12
		if idx == 6 or idx ==0 or cells[idx]==0:
			break
		num = cells[idx]
		cells[idx] = 0

			
	for i in range(cell_nodes.size()):
		_update_cell_label(cell_nodes[i], i)

	current_player = 2 if current_player == 1 else 1
	_auto_select_valid_cell()

# === 6. TỰ ĐỘNG CHỌN Ô HỢP LỆ ===
func _auto_select_valid_cell():
	if current_player == 1:
		for i in range(1, 6):
			if _is_valid_move(i):
				selected_index = i
				_highlight_selected()
				return
	elif current_player == 2:
		for i in range(7, 12):
			if _is_valid_move(i):
				selected_index = i
				_highlight_selected()
				return

# === 7. KIỂM TRA Ô CÓ HỢP LỆ KHÔNG ===
func _is_valid_move(index: int) -> bool:
	# Người chơi 1 chỉ được chọn ô 1–5, người chơi 2 chỉ được chọn ô 7–11
	if index == 0 or index == 6:
		return false
	if current_player == 1 and index >= 1 and index <= 5:
		return cells[index] > 0
	elif current_player == 2 and index >= 7 and index <= 11:
		return cells[index] > 0
	return false

# === 8. CẬP NHẬT GIAO DIỆN SỐ QUÂN TRONG Ô ===
func _update_cell_label(cell_node: Node, i: int):
	var label = cell_node.get_node("Label")
	if label:
		label.text = str(cells[i])
		label.modulate = Color.WHITE

# === 9. TÔ SÁNG Ô ĐANG ĐƯỢC CHỌN ===
func _highlight_selected():
	for i in range(12):
		var label = cell_nodes[i].get_node("Label")
		if label:
			label.modulate = Color.WHITE
	if cell_nodes[selected_index]:
		var label = cell_nodes[selected_index].get_node("Label")
		if label:
			label.modulate = Color.YELLOW
