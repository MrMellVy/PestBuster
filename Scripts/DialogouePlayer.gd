extends CanvasLayer

signal dialogue_finished
var dialogue = []
var current_dialogue_id = 0
var d_active = false

func _ready() -> void:
	$NinePatchRect.visible = false

func start(dialogue_name: String):
	if d_active:
		return
	var target_file_path = "res://Scripts/Dialogue/" + dialogue_name + ".json"
	d_active = true
	$NinePatchRect.visible = true
	
	dialogue = load_dialogue(target_file_path)

	
	#stop the game from crashing if dialogue is null/empty
	if dialogue == null or dialogue.is_empty():
		print("Dialogue array is empty or null. Check the errors above.")
		$NinePatchRect.visible = false
		d_active = false
		return
	current_dialogue_id = -1
	next_script()

func load_dialogue(file_path):
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var content = file.get_as_text()
		
		var json = JSON.new()
		var parse_result = json.parse(content)
		
		if parse_result == OK:
			return json.data
		else:
			print("JSON ERROR in ", file_path)
			print("Line ", json.get_error_line(), ": ", json.get_error_message())
			return []
	else:
		print("ERROR: Godot cannot find any file at path: ", file_path)
		return []
	
func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("attack"):
		if $NinePatchRect/AnimationPlayer.is_playing():
			$NinePatchRect/AnimationPlayer.stop()
			$NinePatchRect/Dialogue.visible_ratio = 1.0
		else:
			next_script()

func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$NinePatchRect.visible = false
		dialogue_finished.emit()
		return
	$NinePatchRect/Name.text = dialogue[current_dialogue_id]['name']
	$NinePatchRect/Dialogue.text = dialogue[current_dialogue_id]['text']

	var face_name = dialogue[current_dialogue_id]['face']
	$NinePatchRect/PictureProtait.texture = load("res://Assets/Sprites/PlayerFace/" + face_name + ".png")
	
	$NinePatchRect/AnimationPlayer.stop()
	$NinePatchRect/AnimationPlayer.play("Dialogue")

func stop() -> void:
	d_active = false
	$NinePatchRect.visible = false
