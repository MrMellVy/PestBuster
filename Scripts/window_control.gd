extends OptionButton

var size_names = ["Small", "Medium", "Maximazed"]
var size_values = [
	Vector2i(640, 360),
	Vector2i(1280,720),
	Vector2i(1920,1080)
]

func _ready() -> void:
	_show_item_selected()


func _on_item_selected(index: int) -> void:
	var new_size = size_values[index]
	get_window().size = new_size
	var screen_size = DisplayServer.screen_get_size()
	var new_pos = (screen_size - new_size) / 2
	get_window().position = new_pos

func _show_item_selected() -> void:
	for i in size_names.size():
		add_item(size_names[i], i)

	var current_size = get_window().size
	for i in size_values.size():
		if size_values[i] == current_size:
			selected = i
			break
