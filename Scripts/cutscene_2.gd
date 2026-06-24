extends Node2D
@onready var world_camera: Camera2D = $Player/WorldCamera
@onready var player_sprite: AnimatedSprite2D = $Player/AnimatedSprite2D

var current_dialogue_index: int = 0
var advance_action: StringName = "attack"
var anim_is_moving: bool = false

var dialogue_is_active: bool = true
var max_lines: int = 6
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fade_transition.show()    
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out")
	BgmManager.play_BGM("cyberpunk-street")
	start()
	world_camera.make_current()
	$Player/CanvasLayer/HealthBarContainer/PlayerHP.visible = false
	var player = $Player
	player.set_process(false)
	player.set_physics_process(false)
	player.set_collision_layer_value(1, false) 
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _input(event: InputEvent) -> void:
	if not dialogue_is_active:
		return

	if anim_is_moving:
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed(advance_action):
		if current_dialogue_index >= max_lines:
			return
		
		current_dialogue_index += 1
		print("Dialogue Index: ", current_dialogue_index)
		#Index always start from zero yeah. 1,2,3,4 -> 0,1,2,3.
		if current_dialogue_index == 3:
			await move_player_to_target($Target_Move3)
		elif current_dialogue_index == 5:
			await move_player_to_target($Target_Move5)
			
func start() -> void:
	Dialouge.start("CS_00")
	await  Dialouge.dialogue_finished
	
	dialogue_is_active = false
	
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")
	await  $Fade_transition/Fade_transition/AnimationPlayer.animation_finished
	
	get_tree().change_scene_to_file("res://Scenes/Level/level_1.tscn")



func move_player_to_target(target_node: Node2D) -> void:
	anim_is_moving = true
	
	var player = $Player
	if target_node.global_position.x > player.global_position.x:
		player.toggle_flip_sprite(1)
	else:
		player.toggle_flip_sprite(-1)
	player.PlayerSprite.play("run")

	var tween = create_tween()
	tween.tween_property(player, "global_position", target_node.global_position, 1.5)
	await tween.finished
	player.PlayerSprite.play("idle")
	anim_is_moving = false
