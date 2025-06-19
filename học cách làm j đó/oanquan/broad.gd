extends Node2D

# === 1. HẰNG SỐ VÀ BIẾN TOÀN CỤC ===
const CELL_SCENE := preload("res://oanquan/cell.tscn")

var cells: Array[int] = [0, 5, 5, 5, 5, 5, 0, 5, 5, 5, 5, 5]
var cell_nodes: Array[Node] = []
var selected_index := 0
var current_player := 1
var waiting_for_direction := false
var score_p1 := 0
var score_p2 := 0


# === 2. KHỞI TẠO BÀN CHƠI ===
func _ready():
	for i in range(12):
		var cell = CELL_SCENE.instantiate()
		cell.cell_index = i
		var y = int(i / 6)
		var display_index = i
		if i >= 6:
			display_index = 11 - i + 6
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
				elif event.keycode == KEY_S and _is_valid_move(selected_index):
					waiting_for_direction = true
			elif current_player == 1:
				if event.keycode == KEY_LEFT:
					_move_selection(-1)
				elif event.keycode == KEY_RIGHT:
					_move_selection(1)
				elif event.keycode == KEY_DOWN and _is_valid_move(selected_index):
					waiting_for_direction = true
		else:
			if event.keycode == KEY_UP or event.keycode == KEY_W:
				waiting_for_direction = false
			elif (event.keycode == KEY_D and current_player == 2) or (event.keycode == KEY_LEFT and current_player == 1):
				await _play_turn(selected_index, false)
				waiting_for_direction = false
			elif (event.keycode == KEY_A and current_player == 2) or (event.keycode == KEY_RIGHT and current_player == 1):
				await _play_turn(selected_index, true)
				waiting_for_direction = false

# === 4. DI CHUYỂN CON TRỎ CHỌN Ô ===
func _move_selection(offset: int):
	for _i in range(12):
		selected_index = (selected_index + offset + 12) % 12
		if _is_valid_move(selected_index):
			break
	_highlight_selected()

# === 5. CHƠI MỘT LƯỢT ===
func _play_turn(index: int, clockwise: bool) -> void:
	var num = cells[index]
	cells[index] = 0
	var idx = index

	# RẢI QUÂN CÓ HIỆU ỨNG
	while num > 0:
		idx = (idx + (1 if clockwise else -1) + 12) % 12
		cells[idx] += 1
		num -= 1
		_update_cell_label(cell_nodes[idx], idx)
		await get_tree().create_timer(0.15).timeout

	# NẾU Ô TIẾP THEO CÓ QUÂN 
	while true:
		var next_idx = (idx + (1 if clockwise else -1) + 12) % 12
		if cells[next_idx] > 0:
			num = cells[next_idx]
			cells[next_idx] = 0
			_update_cell_label(cell_nodes[next_idx], next_idx)
			idx = next_idx
			while num > 0:
				idx = (idx + (1 if clockwise else -1) + 12) % 12
				cells[idx] += 1
				num -= 1
				_update_cell_label(cell_nodes[idx], idx)
				await get_tree().create_timer(0.15).timeout
		else:
			break

	# KIỂM TRA ĂN
	while true:
		var next = (idx + (1 if clockwise else -1) + 12) % 12
		var next_next = (next + (1 if clockwise else -1) + 12) % 12

		if cells[next] == 0 and cells[next_next] > 0:
			if next_next == 0 or next_next == 6:
				if cells[next_next] >= 5:
					_eat(next_next)
					break
				else:
					break
			else:
				_eat(next_next)
				idx = next_next
				continue
		else:
			break

	# CẬP NHẬT
	for i in range(12):
		_update_cell_label(cell_nodes[i], i)

	if _has_no_moves():
		_refill_cells()

	current_player = 2 if current_player == 1 else 1
	_auto_select_valid_cell()

# === 6. ĂN QUÂN ===
func _eat(i: int):
	if current_player == 1:
		score_p1 += cells[i]
	else:
		score_p2 += cells[i]
	cells[i] = 0
	$diem1.text = str(++score_p1)
	$diem2.text = str(++score_p2)
	_update_cell_label(cell_nodes[i], i)

# === 7. HẾT QUÂN PHẢI RẢI LẠI ===
func _has_no_moves() -> bool:
	var range_start = 1 if current_player == 1 else 7
	for i in range(range_start, range_start + 5):
		if cells[i] > 0:
			return false
	return true

func _refill_cells():
	var range_start = 1 if current_player == 1 else 7
	var score_ref = score_p1 if current_player == 1 else score_p2
	if score_ref < 5:
		if current_player == 1:
			var borrow = 5 - score_p1
			score_p1 = 0
			score_p2 = max(score_p2 - borrow, 0)
		else:
			var borrow = 5 - score_p2
			score_p2 = 0
			score_p1 = max(score_p1 - borrow, 0)
	else:
		if current_player == 1:
			score_p1 -= 5
		else:
			score_p2 -= 5
	for i in range(range_start, range_start + 5):
		cells[i] = 1
		_update_cell_label(cell_nodes[i], i)

# === 8. TỰ ĐỘNG CHỌN Ô ===
func _auto_select_valid_cell():
	var range_start = 1 if current_player == 1 else 7
	for i in range(range_start, range_start + 5):
		if _is_valid_move(i):
			selected_index = i
			_highlight_selected()
			return

# === 9. KIỂM TRA Ô HỢP LỆ ===
func _is_valid_move(index: int) -> bool:
	if index == 0 or index == 6:
		return false
	if current_player == 1 and index >= 1 and index <= 5:
		return cells[index] > 0
	elif current_player == 2 and index >= 7 and index <= 11:
		return cells[index] > 0
	return false

# === 10. CẬP NHẬT GIAO DIỆN ===
func _update_cell_label(cell_node: Node, i: int):
	var label = cell_node.get_node("Label")
	if label:
		label.text = str(cells[i])
		label.modulate = Color.WHITE

# === 11. TÔ SÁNG Ô ===
func _highlight_selected():
	for i in range(12):
		var label = cell_nodes[i].get_node("Label")
		if label:
			label.modulate = Color.WHITE
	if cell_nodes[selected_index]:
		var label = cell_nodes[selected_index].get_node("Label")
		if label:
			label.modulate = Color.YELLOW
