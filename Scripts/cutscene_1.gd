extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

var current_dialogue_index: int = 0
var advance_action: StringName = "attack"

var dialogue_is_active: bool = true
var max_lines: int = 8


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fade_transition.show()    
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out")
	BgmManager.play_BGM("cyberpunk-street")
	Dialouge.dialogue_event.connect(_on_dialogue_event)
	start()

func _on_dialogue_event(event_name: String) -> void:
	if event_name == "car_crash":
		animation_player.play("carwew")
		animation_player_2.play("rtwew")

func _input(event: InputEvent) -> void:
	if not dialogue_is_active:
		return

	if event.is_action_pressed(advance_action):
		if Dialouge.get_node("NinePatchRect/AnimationPlayer").is_playing():
			return

func start() -> void:
	animation_player.play("car")
	Dialouge.start("CS_00")
	await  Dialouge.dialogue_finished
	dialogue_is_active = false
	if animation_player.is_playing() or animation_player_2.is_playing():
		await animation_player.animation_finished
		
	get_tree().change_scene_to_file("res://Scenes/Level/level_1.tscn")
