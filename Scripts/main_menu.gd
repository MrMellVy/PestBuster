extends Control

var button_type = null
var fade_startup = false
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings_menu: Control = $Options

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	settings_menu.visible = false
	$title.visible = true
	$Fade_transition.show()
	$Fade_transition/fade_timerstart.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out") 
	BgmManager.play_BGM("cyber_runner")
	fade_startup = true
	handle_connecting_signals()

func _on_start_pressed() -> void:
	button_type = "start"
	await get_tree().process_frame
	if $AnimationBStart.current_animation == "ButtonPressed" and $AnimationBStart.is_playing():
		await $AnimationBStart.animation_finished
	$Fade_transition.show()
	$Fade_transition/fade_timer.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")

func _on_option_pressed() -> void:
	print("Settings Pressed")
	main_buttons.visible = false
	settings_menu.visible = true
	settings_menu.set_process(true)
	$title.visible = false

func _on_exit_pressed() -> void:
	button_type = "exit"
	await get_tree().process_frame
	
	if $AnimationBExit.current_animation == "Buttonexitpressed" and $AnimationBExit.is_playing():
		await $AnimationBExit.animation_finished
	$Fade_transition.show()
	$Fade_transition/fade_timer.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")


func _on_fade_timer_timeout() -> void:
	if button_type == "start" :
		Global.gameStarted = true
		get_tree().change_scene_to_file("res://Scenes/Cutscene/cutscene_1.tscn")
	elif button_type == "exit" :
		get_tree().quit()
	elif fade_startup == true:
		$Fade_transition.hide()

func _on_back_settings_menu() -> void:
	print("it work.")
	main_buttons.visible = true
	settings_menu.visible = false
	$title.visible = true

func handle_connecting_signals() -> void:
	settings_menu.back_settings_menu.connect(_on_back_settings_menu)
