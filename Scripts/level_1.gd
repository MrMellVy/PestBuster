extends Node2D

@onready var SceneTransitionAnimation = $Fade_transition/Fade_transition/AnimationPlayer
var is_transitioning: bool = false

func _ready() -> void:
	$Fade_transition.show()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out")

func _process(delta):
	if !Global.playerAlive and !is_transitioning:
		is_transitioning = true
		Global.gameStarted = false
		$Fade_transition.show()
		SceneTransitionAnimation.play("Fade_in")
		await SceneTransitionAnimation.animation_finished
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
