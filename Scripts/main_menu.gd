extends Node2D


var button_type = null
var fade_startup = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fade_transition.show()
	$Fade_transition/fade_timerstart.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out") 
	fade_startup = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	button_type = "start"
	$Fade_transition.show()
	$Fade_transition/fade_timer.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")

	

func _on_option_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	button_type = "exit"
	$Fade_transition.show()
	$Fade_transition/fade_timer.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")


func _on_fade_timer_timeout() -> void:
	if button_type == "start" :
		get_tree().change_scene_to_file("res://Scenes/Level/level_1.tscn")
	elif button_type == "exit" :
		get_tree().quit()
	elif fade_startup == true:
		$Fade_transition.hide()
