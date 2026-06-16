extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Fade_transition.show()    
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out")
	BgmManager.play_BGM("cyberpunk-street")
	start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start() -> void:
	animation_player.play("car")
	Dialouge.start("CS_00")
	await  Dialouge.dialogue_finished
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_in")
	await  $Fade_transition/Fade_transition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://Scenes/Level/level_1.tscn")
