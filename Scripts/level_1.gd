extends Node2D

@onready var SceneTransitionAnimation = $Fade_transition/Fade_transition/AnimationPlayer
@onready var world_camera: Camera2D = $Player/WorldCamera


var current_wave: int
@export var enemy_scene: PackedScene

var last_spawn_position: Vector2 = Vector2(-9999, -9999)  
var min_spawn_distance: float = 100.0
var wave_spawn_ended: bool = false
var is_transitioning: bool = false
var current_wave_batches: Array = []
var current_batch_index: int = 0
var is_spawning: bool = false
var enemies_alive: int = 0
var rand_x
var rand_y

func _ready() -> void:
	world_camera.make_current()
	$Fade_transition.show()
	$Fade_transition.layer = 2
	$Fade_transition/Fade_transition/AnimationPlayer.play("Fade_out_start")
	BgmManager.play_BGM("Battle Encounter")
	
	if Global.is_continuing:
		current_wave = Global.saved_wave - 1
		$Player.health = Global.saved_player_health
		$Player.damage_bonus = Global.saved_player_damage_bonus
		$scoreLabels.layer = 3
		position_to_next_wave()
		current_wave_batches = [3 + current_wave, 5 + current_wave]
		current_batch_index = 0
		spawn_next_batch()
	else:
		current_wave = 0
		Global.current_wave = current_wave
		
		await SceneTransitionAnimation.animation_finished
		$scoreLabels.layer = 3
		$scoreLabels/MiddleWaveAnim.play("LeftStart")
		await $scoreLabels/MiddleWaveAnim.animation_finished
		position_to_next_wave()

func position_to_next_wave():
		if current_wave != 0:
			Global.moving_to_next_wave = true
		wave_spawn_ended = false
		is_spawning = true
		
		$Fade_transition.layer = 1
		$scoreLabels/ScoreAnim.play("ScoreDown")
		$scoreLabels/WaveAnim.play("WaveDown")
		$scoreLabels/MiddleWaveAnim.play("RightExit")
		SceneTransitionAnimation.play("between_wave")
		current_wave += 1
		Global.current_wave = current_wave
		$Player.apply_wave_stats(current_wave)
		
		if current_wave == 1:
			# Wave 1 will spawn 2 enemies, then 4, then 3
			current_wave_batches = [2, 4, 3]
		elif current_wave == 3:
			if Global.is_continuing:
				Global.is_continuing = false
				return
			else:
				Global.saved_wave = current_wave
				Global.is_continuing = true
				Global.saved_player_health = $Player.health
				Global.saved_player_damage_bonus = $Player.damage_bonus
				get_tree().change_scene_to_file("res://Scenes/Cutscene/cutscene_1.tscn")
		else:
			# Wave 2 just add math bro. 3+2,5,3.
			current_wave_batches = [3 + current_wave, 5 + current_wave]
		current_batch_index = 0
		
		#Fix for freeze bug happens when close the window.
		if is_inside_tree():
			await get_tree().create_timer(0.5).timeout
			if is_inside_tree():
				spawn_next_batch()

func spawn_next_batch():
	if not is_inside_tree(): return
	
	if current_batch_index > 0:
		if is_inside_tree():
			await  get_tree().create_timer(1.0).timeout
		if not is_inside_tree(): return
	var enemies_to_spawn = current_wave_batches[current_batch_index]
	
	for i in range(enemies_to_spawn):
		var enemy = enemy_scene.instantiate()
		enemy.z_index = 1

		# random spawn for SpawnPoint1 and SpawnPoint2
		if i % 2 == 0:
			enemy.global_position = $EnemySpawnPoint1.global_position
		else:
			enemy.global_position = $EnemySpawnPoint2.global_position
		enemy.tree_exited.connect(check_enemy_count)
		
		enemies_alive += 1
		add_child(enemy)
		await get_tree().create_timer(0.4).timeout 
		
	current_batch_index += 1
	
	if current_batch_index >= current_wave_batches.size():
		wave_spawn_ended = true
		
	is_spawning = false
	
	if enemies_alive <= 0:
		trigger_next_phase()
		
func check_enemy_count():
	enemies_alive -= 1
	if enemies_alive <= 0 and !is_spawning:
		trigger_next_phase()

func trigger_next_phase():
	is_spawning = true
	if wave_spawn_ended:
		print("Wave Cleared! Starting Next Wave...")
		$scoreLabels/ScoreAnim.play("ScoreUp")
		$scoreLabels/WaveAnim.play("WaveUp")
		$scoreLabels/MiddleWaveAnim.play("LeftStart")
		await $scoreLabels/ScoreAnim.animation_finished
		await $scoreLabels/WaveAnim.animation_finished
		await  $scoreLabels/MiddleWaveAnim.animation_finished
		position_to_next_wave()
	else:
		print("Batch Cleared! Spawning next batch...")
		is_spawning = true
		spawn_next_batch()

func _process(_delta):
	if !Global.playerAlive and !is_transitioning:
		is_transitioning = true
		Global.gameStarted = false
		$Fade_transition.show()
		$Fade_transition.layer = 2
		SceneTransitionAnimation.play("Fade_in")
		await SceneTransitionAnimation.animation_finished
		update_score()
		get_tree().change_scene_to_file("res://Scenes/Retry.tscn")
			
func update_score():
	Global.previous_score = Global.current_score
	if Global.current_score > Global.high_score:
		Global.high_score = Global.current_score
		Global.current_score = 0


func _on_timer_health_power_up_timeout() -> void:
	var active_powerups = get_tree().get_nodes_in_group("health_powerups")
	var current_count = active_powerups.size()
	
	# If there are 3 or more on screen, skip spawning.
	if current_count > 2:
		print("Waiting... Powerups on screen: ", current_count)
		return
	var obj = preload("res://Scenes/SpawnHealth.tscn").instantiate()
	
	var valid_position = false
	var new_position: Vector2
	var max_attempts = 10
	
	for attempt in range(max_attempts):
		rand_x = randi_range(-435, 550)
		rand_y = -70
		new_position = Vector2(rand_x, rand_y)
	
		var distance_from_last = new_position.distance_to(last_spawn_position)
		
		var too_close_to_any = false
		for powerup in active_powerups:
			var distance_to_powerup = new_position.distance_to(powerup.global_position)
			if distance_to_powerup < min_spawn_distance:
				too_close_to_any = true
				break
				
		if distance_from_last >= min_spawn_distance and not too_close_to_any:
			valid_position = true
			break
		
	obj.global_position = new_position
	last_spawn_position = new_position
	
	obj.add_to_group("health_powerups")
	
	#powerup fall from the sky can bypass the platfrom and fall to the ground. By 50%
	if randf() < 0.5:
		obj.set_collision_mask_value(4, false)
	add_child(obj)

	var cooldown = 20
	if current_wave > 1:
		cooldown = 17.0 - ((current_wave - 2) * 2.0)
		cooldown = max(cooldown, 10.0)
	cooldown = max(cooldown, 10.0)
	$TimerHealthPowerUp.wait_time = cooldown
	print("Health Cooldown set to: ", cooldown, " seconds for Wave ", current_wave)
