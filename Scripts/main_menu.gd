extends Control

var button_type = null
var fade_startup = false
@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings_menu: Control = $Options
@onready var selected_camera: Camera2D = $Camera2D
@onready var transition_camera: Camera2D = $TransitionCamera
@onready var continue_button: TextureButton = $MainButtons/Button_Manager/Continue
@onready var reset_hold_bar: TextureProgressBar = $ResetHoldbar

var TransitionTween: Tween
var TransitionZoomTween: Tween
var TransitionOffsetTween: Tween

var esc_hold_time: float = 0.0
var esc_reset_done: bool = false
const ESC_HOLD_TIME: float = 3.0

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
	
	var has_save := Savedata.has_valid_save()
	
	$MainButtons/Button_Manager/Start.visible = not has_save
	continue_button.visible = has_save
	continue_button.disabled = not has_save
	if not continue_button.pressed.is_connected(_on_continue_pressed):
		continue_button.pressed.connect(_on_continue_pressed)
	
	print("has save: ", Savedata.has_save(), ", scene path: ", Savedata.scene_path, ", valid save: ", Savedata.has_valid_save())

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if not esc_reset_done:
			esc_hold_time += delta
			reset_hold_bar.visible = true
			reset_hold_bar.value = esc_hold_time / ESC_HOLD_TIME * 100.0
			
		if esc_hold_time >= ESC_HOLD_TIME:
			Savedata.reset_save()
			esc_reset_done = true
			
			continue_button.visible = false
			continue_button.disabled = true
			
			reset_hold_bar.value = 100.0
			print("ASave deleted")
	else :
		esc_hold_time = 0.0
		esc_reset_done = false
		reset_hold_bar.visible = false
		reset_hold_bar.value = 0.0

func _on_start_pressed() -> void:
	button_type = "start"
	await get_tree().process_frame
	if $AnimationBStart.current_animation == "ButtonPressed" and $AnimationBStart.is_playing():
		await $AnimationBStart.animation_finished
	$Fade_transition.show()
	$Fade_transition/fade_timer.start()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")

func _on_continue_pressed() -> void:
	if not Savedata.has_valid_save():
		return
	
	continue_button.visible = true
	button_type = "continue"
	
	$Fade_transition.show()
	$Fade_transition/fade_timerstart.start()
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
		Savedata.save_checkpoint(
			"res://Scenes/Cutscene/cutscene_1.tscn",
			1,
			100,
			0
		)
		get_tree().change_scene_to_file("res://Scenes/Cutscene/cutscene_1.tscn")
	elif button_type == "continue":
		Global.gameStarted = true
		
		Savedata.load_checkpoint()
		
		Global.is_continuing = true
		Global.saved_wave = Savedata.wave
		Global.saved_player_health = Savedata.health
		Global.saved_player_damage_bonus = Savedata.damage_bonus
		
		get_tree().change_scene_to_file(Savedata.scene_path)
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
	TransitionTween.tween_property(transition_camera, "global_transform", target_transform, 1).set_trans(Tween.TRANS_SINE)
	
	if TransitionZoomTween:
		TransitionZoomTween.kill()
	TransitionZoomTween = create_tween()
	var target_zoom: Vector2 = choose_camera.zoom
	TransitionZoomTween.tween_property(transition_camera, "zoom", target_zoom, 1).set_trans(Tween.TRANS_SINE)
	
	if TransitionOffsetTween:
		TransitionOffsetTween.kill()
	TransitionOffsetTween = create_tween()
	var target_offset: Vector2 = choose_camera.offset
	TransitionOffsetTween.tween_property(transition_camera, "offset", target_offset, 1).set_trans(Tween.TRANS_SINE)

	selected_camera = choose_camera
