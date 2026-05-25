extends TextureButton

var original_pos: Vector2
@onready var anim_player = $"../../ButtonsAnimation2"

func _ready() -> void:
	original_pos = position
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	anim_player.play("buttonexit")

func _on_mouse_exited() -> void:
	anim_player.stop()
