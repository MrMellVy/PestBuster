extends Node2D

@onready var SceneTransitionAnimation = $Fade_transition/Fade_transition/AnimationPlayer

var current_wave: int
@export var enemy_scene:PackedScene

var starting_nodes: int
var current_nodes: int
var wave_spawn_ended
var is_transitioning: bool = false

func _ready() -> void:
	$Fade_transition.show()
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out")
	current_wave = 0
	Global.current_wave = current_wave
	starting_nodes = get_child_count()
	current_nodes = get_child_count()
	position_to_next_wave()

func position_to_next_wave():
	if current_nodes == starting_nodes:
		if current_wave != 0:
			Global.moving_to_next_wave = true
		wave_spawn_ended = false
		SceneTransitionAnimation.play("between_wave")
		current_wave += 1
		Global.current_wave = current_wave
		await get_tree().create_timer(0.5).timeout
		prepare_spawn("enemy", 4.0, 4.0) # type, multiplier, spwans
		print(current_wave)

func prepare_spawn(type, multiplier, mob_spawns):
	var mob_amount = float(current_wave) * multiplier
	var mob_wait_time: float = 2.0
	print("mob_amount: ", mob_amount)
	var mob_spawn_rounds = mob_amount/mob_spawns
	spawn_type(type, mob_spawn_rounds, mob_wait_time)

func spawn_type(type, mob_spawn_rounds, mob_wait_time):
	if type == "enemy":
		var enemy_spawn1 = $EnemySpawnPoint1
		var enemy_spawn2 = $EnemySpawnPoint2
		if mob_spawn_rounds >= 1:
			
			for i in int(mob_spawn_rounds):
				var enemy1 = enemy_scene.instantiate()
				enemy1.global_position = enemy_spawn1.global_position
				var enemy2 = enemy_scene.instantiate()
				enemy2.global_position = enemy_spawn2.global_position
				add_child(enemy1)
				add_child(enemy2)
				await get_tree().create_timer(mob_wait_time).timeout
			wave_spawn_ended = true
			
			
func _process(delta):
	if !Global.playerAlive and !is_transitioning:
		is_transitioning = true
		Global.gameStarted = false
		$Fade_transition.show()
		SceneTransitionAnimation.play("Fade_in")
		await SceneTransitionAnimation.animation_finished
		update_score()
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
	current_nodes = get_child_count()
	
	if wave_spawn_ended:
		print("test")
		position_to_next_wave()

func update_score():
	Global.previous_score = Global.current_score
	if Global.current_score > Global.high_score:
		Global.high_score = Global.current_score
		Global.current_score = 0
