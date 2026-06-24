extends TextureButton

var original_pos: Vector2
var is_mouse_mode: bool = false
@onready var animation_player_2: AnimationPlayer = $"../../AnimationPlayer2"


func _ready() -> void:
	original_pos = position
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.relative.length() > 1.0 and not is_mouse_mode:
			is_mouse_mode = true
			release_focus() 
	elif event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if is_mouse_mode:
			is_mouse_mode = false
			grab_focus() 

func _on_mouse_entered() -> void:
	animation_player_2.play("buttonexit")

func _on_mouse_exited() -> void:
	animation_player_2.stop()

func _on_focus_entered() -> void:
	animation_player_2.play("buttonexit")

func _on_focus_exited() -> void:
	animation_player_2.stop()


func _on_button_down() -> void:
	animation_player_2.stop()
	if not is_mouse_mode:
		animation_player_2.play("Buttonexitpressed")
		await  animation_player_2.animation_finished
func _on_button_up() -> void:
	pass
