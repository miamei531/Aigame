extends Node2D

const CELL_SCENE := preload("res://oanquan/cell.tscn")

var cells: Array[int] = [5, 5, 5, 5, 5, 5, 0, 5, 5, 5, 5, 5]
var cell_nodes: Array[Node] = []
var selected_index := 0
var current_player := 1  # 1 hoặc 2

func _ready():
	for i in range(12):
		var cell = CELL_SCENE.instantiate()
		cell.cell_index = i
		cell.position = Vector2(80 + (i % 6) * 70, 200 + int(i / 6) * 100)  # 2 hàng
		add_child(cell)

		cell.cell_pressed.connect(_on_cell_pressed)
		cell_nodes.append(cell)

		_update_cell_label(cell, i)

	_highlight_selected()

func _on_cell_pressed(index: int):
	if not _is_valid_move(index):
		return
	_play_turn(index)

func _play_turn(index: int):
	var num = cells[index]
	cells[index] = 0
	var idx = index
	while num > 0:
		idx = (idx + 1) % 12
		cells[idx] += 1
		num -= 1

	for i in range(cell_nodes.size()):
		_update_cell_label(cell_nodes[i], i)

	# Đổi lượt người chơi
	current_player = 2 if current_player == 1 else 1

	# Tự động chọn ô đầu tiên hợp lệ của người chơi tiếp theo
	_auto_select_valid_cell()

func _update_cell_label(cell_node: Node, i: int):
	var label = cell_node.get_node("Label")
	if label:
		label.text = str(cells[i])
		label.modulate = Color.WHITE

func _highlight_selected():
	for i in range(12):
		var label = cell_nodes[i].get_node("Label")
		if label:
			label.modulate = Color.WHITE
	if cell_nodes[selected_index]:
		var label = cell_nodes[selected_index].get_node("Label")
		if label:
			label.modulate = Color.YELLOW

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if current_player == 1:
			if event.keycode == KEY_A:
				_move_selection(-1)
			elif event.keycode == KEY_D:
				_move_selection(1)
			elif event.keycode == KEY_W or event.keycode == KEY_S:
				_move_selection(6)
			elif event.keycode == KEY_Z or event.keycode == KEY_ENTER:
				if _is_valid_move(selected_index):
					_play_turn(selected_index)
		elif current_player == 2:
			if event.keycode == KEY_LEFT:
				_move_selection(-1)
			elif event.keycode == KEY_RIGHT:
				_move_selection(1)
			elif event.keycode == KEY_UP or event.keycode == KEY_DOWN:
				_move_selection(6)
			elif event.keycode == KEY_SPACE or event.keycode == KEY_KP_ENTER:
				if _is_valid_move(selected_index):
					_play_turn(selected_index)

func _move_selection(offset: int):
	var start_index = selected_index
	for _i in range(12):  # Giới hạn tránh lặp vô hạn
		selected_index = (selected_index + offset + 12) % 12
		if _is_valid_move(selected_index):
			break
	_highlight_selected()

func _auto_select_valid_cell():
	for i in range(12):
		if _is_valid_move(i):
			selected_index = i
			_highlight_selected()
			return

func _is_valid_move(index: int) -> bool:
	return cells[index] > 0
