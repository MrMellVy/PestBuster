extends CharacterBody2D

class_name Enemy

const speed = 40 #The enemy speed.
const push_force = 10.0 # So it doesnt collide with other enemy. Yes, taking the difficult way.
const anim_threshold = 5.0 #Cam be upper than the push_force or lower, idk man.

var is_enemy_chase: bool = true
var health = 40
var health_max = 40
var health_min = 0

var defeat: bool = false
var taking_damage: bool = false
var damage_to_deal = 20
var is_dealing_damage: bool = false
var has_dealt_damage: bool = false
var points_for_kill = 250

var dir: Vector2
const gravity = 900
var knockback_force = -20
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area = false

var can_attack: bool = true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var separate_area: Area2D = $SeparateArea


func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	if Global.playerAlive:
		is_enemy_chase = true
	elif !Global.playerAlive:
		is_enemy_chase = false
	Global.EnemyDamageAmount = damage_to_deal
	Global.EnemyDamageZone = $EnemyDealDamageArea
	player = Global.playerBody
	
	if player_in_area and can_attack and !defeat and !taking_damage:
		attack_sequence()
	
	calculate_movement()
	apply_separation()
	handle_animation()
	move_and_slide()
	
func calculate_movement():
	if player_in_area and player != null:
			var dir_to_player = sign(player.global_position.x - global_position.x)
			if dir_to_player != 0:
				dir.x = dir_to_player

	if defeat or is_dealing_damage:
		velocity.x = 0
		return

	if taking_damage:
		var knockbar_dir = position.direction_to(player.position) * knockback_force
		velocity.x = knockbar_dir.x
		

	if is_enemy_chase and player != null:
		var distance_x = abs(global_position.x - player.global_position.x)
		var distance_y = abs(global_position.y - player.global_position.y)
		
		var in_deadzone = false
		
		if distance_y > 20.0:
			if distance_x < 80.0: in_deadzone = true
		else:
			if distance_x < 15.0: in_deadzone = true
		
		if in_deadzone:
			velocity.x = dir.x * (speed * 0.5)
		else:
			var dir_to_player = sign(player.global_position.x - global_position.x)
			velocity.x = dir_to_player * speed
			dir.x = dir_to_player 
	elif  !is_enemy_chase:
		velocity.x = dir.x * speed
		
	is_roaming = true
	
func handle_animation():
	if defeat:
		return 
	
	if dir.x < 0:
		animated_sprite_2d.flip_h = false
	elif dir.x > 0:
		animated_sprite_2d.flip_h = true
		
	if taking_damage:
		play_enemy_animation("hitted")
	elif is_dealing_damage:
		play_enemy_animation("attack")
	else:
		if abs(velocity.x) > anim_threshold:
			play_enemy_animation("move")
		else:
			play_enemy_animation("idle")


func handle_defeat_sequence():
	is_roaming = false
	play_enemy_animation("defeat")
	velocity.x = 0
	await get_tree().create_timer(1.0).timeout
	handle_defeat()

func handle_defeat():
	Global.current_score += points_for_kill
	self.queue_free()

func _on_direction_timer_timeout() -> void:
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	var random_dir = choose([-1, 1])
	dir.x = random_dir
	
func choose(array):
	array.shuffle()
	return array.front()

func _on_enemy_hitbox_area_entered(area: Area2D) -> void:
	var damage = Global.playerDamageAmount
	if area == Global.playerDamageZone:
		take_damage(damage)
		
func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= health_min:
		health = health_min
		defeat = true
		handle_defeat_sequence()
	else:
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	print(str(self), "current health is ", health)

func attack_sequence():
	can_attack = false
	await  get_tree().create_timer(0.4).timeout

	if defeat or taking_damage:
		can_attack = true
		return
		
	is_dealing_damage = true
	has_dealt_damage = false

	await $AnimatedSprite2D.animation_finished

	is_dealing_damage = false
	await get_tree().create_timer(3.0).timeout
	can_attack = true

func _on_enemy_deal_damage_area_area_entered(area: Area2D) -> void:
	if area == Global.playerHitbox:
		player_in_area = true


func _on_enemy_deal_damage_area_area_exited(area: Area2D) -> void:
	if area == Global.playerHitbox:
		player_in_area = false
	
func play_enemy_animation(anim_name: String):
	animated_sprite_2d.play(anim_name)
	if anim_name == "move":
		animated_sprite_2d.offset.y = -27
	elif anim_name == "defeat":
		animated_sprite_2d.offset.y = -20
	else:
		animated_sprite_2d.offset.y = -7

func apply_separation():
	if defeat or taking_damage or is_dealing_damage or player_in_area: 
		return
	var push_separation = get_separation_x()
	velocity.x += (push_separation * push_force)
	
func get_separation_x() -> float:
	var push_x = 0.0
	var overlapping_bodies = $SeparateArea.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body == self:
			continue
			
		if body.global_position.x == global_position.x:
			push_x += randf_range(-1.0, 1.0) # Panic shove left or right
		else:
			if body.global_position.x < global_position.x:
				push_x += 1.0
			else:
				push_x -= 1.0
				
	return sign(push_x)
