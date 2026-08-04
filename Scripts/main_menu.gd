extends Control

var button_type = null
var fade_startup = false
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings_menu: Control = $Options
@onready var selected_camera: Camera2D = $Camera2D
@onready var transition_camera: Camera2D = $TransitionCamera

var TransitionTween: Tween
var TransitionZoomTween: Tween
var TransitionOffsetTween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	#settings_menu.visible = false
	$title.visible = true
	$Fade_transition.show()
	$Fade_transition/fade_timerstart.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out") 
	BgmManager.play_BGM("cyber_runner")
	fade_startup = true
	$TransitionCamera.make_current()
	_change_camera($Camera2D)
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
	#main_buttons.visible = false
	#settings_menu.visible = true
	#settings_menu.set_process(true)
	#$title.visible = false
	#$RichTextLabel.visible = false
	if selected_camera == $Camera2D:
		_change_camera($Camera2D2)
	else:
		_change_camera($Camera2D)

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
	#main_buttons.visible = true
	#settings_menu.visible = false
	#$title.visible = true
	#$RichTextLabel.visible = true
	if $AnimationBSettings.current_animation == "ButtonSettingsPressed" and $AnimationBSettings.is_playing():
		await $AnimationBSettings.animation_finished
	if selected_camera == $Camera2D2:
		_change_camera($Camera2D)
	else:
		_change_camera($Camera2D2)
	
func handle_connecting_signals() -> void:
	settings_menu.back_settings_menu.connect(_on_back_settings_menu)

func _change_camera(choose_camera: Camera2D) -> void:
	if TransitionTween:
		TransitionTween.kill()
	TransitionTween = create_tween()
	var target_transform: Transform2D = choose_camera.global_transform
	TransitionTween.tween_property(transition_camera, "global_transform", target_transform, 0.5).set_trans(Tween.TRANS_SINE)
	
	if TransitionZoomTween:
		TransitionZoomTween.kill()
	TransitionZoomTween = create_tween()
	var target_zoom: Vector2 = choose_camera.zoom
	TransitionZoomTween.tween_property(transition_camera, "zoom", target_zoom, 0.5).set_trans(Tween.TRANS_SINE)
	
	if TransitionOffsetTween:
		TransitionOffsetTween.kill()
	TransitionOffsetTween = create_tween()
	var target_offset: Vector2 = choose_camera.offset
	TransitionOffsetTween.tween_property(transition_camera, "offset", target_offset, 0.5).set_trans(Tween.TRANS_SINE)

	selected_camera = choose_camera
