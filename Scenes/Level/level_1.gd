extends Node2D

func _ready() -> void:
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out")
