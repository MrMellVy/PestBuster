extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fade_transition.hide = false
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out")
