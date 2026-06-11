extends CharacterBody2D

class_name Enemy

const speed = 30
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

func _process(delta: float) -> void:
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
	
	move(delta)
	handle_animation()
	move_and_slide()
	
func move(delta):
	if defeat:
		velocity.x = 0
		return
	if is_dealing_damage:
		velocity.x = 0
		return
		
	if !is_enemy_chase:
		velocity += dir * speed * delta
	elif taking_damage:
		var knockbar_dir = position.direction_to(player.position) * knockback_force
		velocity.x = knockbar_dir.x
	elif player_in_area:
		velocity.x = 0
	elif is_enemy_chase:
		var dir_to_player = position.direction_to(player.position) * speed
		velocity.x = dir_to_player.x
		if velocity.x != 0:
			dir.x = abs(velocity.x) / velocity.x
	is_roaming = true

func handle_animation():	
	if defeat:
		return 
		
	if taking_damage:
		play_enemy_animation("hitted")
	elif is_dealing_damage:
		play_enemy_animation("attack")
	else:
		if velocity.x == 0:
			play_enemy_animation("idle")
		else:
			play_enemy_animation("move")
		if dir.x == -1:
			animated_sprite_2d.flip_h = false
		elif dir.x == 1:
			animated_sprite_2d.flip_h = true

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
	if !is_enemy_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0
	
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
	is_dealing_damage = true
	has_dealt_damage = false
	await $AnimatedSprite2D.animation_finished
	is_dealing_damage = false
	await get_tree().create_timer(3).timeout
	can_attack = true

func _on_enemy_deal_damage_area_area_entered(area: Area2D) -> void:
	if area == Global.playerHitbox:
		player_in_area = true


func _on_enemy_deal_damage_area_area_exited(area: Area2D) -> void:
	if area == Global.playerHitbox:
		player_in_area = false
	
func play_enemy_animation(anim_name: String):
	animated_sprite_2d.play(anim_name)
	if anim_name == "defeat" or anim_name == "move":
		animated_sprite_2d.offset.y = -27
	else:
		animated_sprite_2d.offset.y = -7
