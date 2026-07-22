extends Node2D
@onready var camerehere: Camera2D = $Player/Camerehere
@onready var world_camera: Camera2D = $Player/WorldCamera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_camera.make_current()
	$Fade_transition.show()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out")
