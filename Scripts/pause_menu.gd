extends CanvasLayer

@onready var fade_transition: CanvasLayer = $Fade_transition


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	get_tree().paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	fade_transition.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	visible = false
	get_tree().paused = false
	
func _on_button_menu_pressed() -> void:
	fade_transition.visible = true
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")
	await $Fade_transition/Fade_transition/AnimationPlayer.animation_finished
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			$BackgroundAnim.play("Outro")
			$ButtonAnim.play("ButtonOutro")
			$BMenuAnim.play("OutroMenu")
			await $BackgroundAnim.animation_finished
			await $ButtonAnim.animation_finished
			await $BMenuAnim.animation_finished
			visible = false
			get_tree().paused = false
		else:
			$BackgroundAnim.play("Intro")
			$ButtonAnim.play("ButtonIntro")
			$BMenuAnim.play("IntroMenu")
			visible = true
			get_tree().paused = true
