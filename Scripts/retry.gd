extends CanvasLayer
var fade_on = false
var button_type = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fade_transition.show()
	$Fade_transition/fade_timerstart.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out")
	BgmManager.play_retry_music("Retry")
	$AnimationPlayer.play("Title")
	fade_on = true




func _on_fade_timer_timeout() -> void:
	if button_type == "retry" :
		Global.gameStarted = true
		get_tree().change_scene_to_file("res://Scenes/Level/level_1.tscn")
	elif button_type == "menu" :
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	elif fade_on == true:
		$Fade_transition.hide()

func _on_fade_timerstart_timeout() -> void:
	if button_type == "retry" :
		Global.gameStarted = true
		get_tree().change_scene_to_file("res://Scenes/Level/level_1.tscn")
	elif button_type == "menu" :
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	elif fade_on == true:
		$Fade_transition.hide()

func _on_retry_pressed() -> void:
	button_type = "retry"
	$Fade_transition.show()
	$Fade_transition/fade_timer.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")

func _on_menu_pressed() -> void:
	button_type = "menu"
	$Fade_transition.show()
	$Fade_transition/fade_timer.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")
