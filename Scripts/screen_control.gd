extends OptionButton

func _ready() -> void:
	_show_item_selected()

func _on_item_selected(index: int) -> void:
	var window_modes = [
		DisplayServer.WINDOW_MODE_WINDOWED,
		DisplayServer.WINDOW_MODE_FULLSCREEN,
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	]
	DisplayServer.window_set_mode(window_modes[index])
	print(index)

func _show_item_selected() -> void:
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		selected = 0
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		selected = 1
	if current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		selected = 2
