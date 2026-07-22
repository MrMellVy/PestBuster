extends CanvasLayer

signal dialogue_finished
signal dialogue_event(event_name: String)
@export var test_dialogue: String = ""

var dialogue = []
var current_dialogue_id = 0
var d_active = false

func _ready() -> void:
	$NinePatchRect.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

	if get_tree().current_scene == self and test_dialogue != "":
		start(test_dialogue)
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
		print("error can't find any file at path: ", file_path)
		return []
	
func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("attack") or event.is_action_pressed("ui_accept"):
		if $NinePatchRect/AnimationPlayer.is_playing():
			$NinePatchRect/AnimationPlayer.stop()
			$NinePatchRect/Dialogue.visible_ratio = 1.0
			$NinePatchRect/AnimationPlayer.animation_finished.emit("Dialogue")
		else:
			next_script()

func next_script():
	current_dialogue_id += 1
	if current_dialogue_id >= len(dialogue):
		d_active = false
		$NinePatchRect.visible = false
		dialogue_finished.emit()
		return
	
	var current_line = dialogue[current_dialogue_id]
	$NinePatchRect/Name.text = current_line.get("name","Unw")
	$NinePatchRect/Dialogue.text = current_line.get('text',"...")

	var face_name = current_line.get("face","")
	if face_name != "":
		var texture_path = "res://Assets/Sprites/PlayerFace/" + face_name + ".png"
		if ResourceLoader.exists(texture_path):
			$NinePatchRect/PictureProtait.texture = load(texture_path)
		else:
			print("Face texture not found at", texture_path)
			$NinePatchRect/PictureProtait.texture = null
	else:
		$NinePatchRect/PictureProtait.texture = null

	$NinePatchRect/AnimationPlayer.stop()
	$NinePatchRect/AnimationPlayer.play("Dialogue")
	
	if current_line.has("event"):
		dialogue_event.emit(current_line["event"])
	
	if current_line.has("auto"):
		await $NinePatchRect/AnimationPlayer.animation_finished
		await get_tree().create_timer(current_line["auto"]).timeout
		if d_active and dialogue[current_dialogue_id] == current_line:
			next_script()

func stop() -> void:
	d_active = false
	$NinePatchRect.visible = false
