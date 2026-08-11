extends CharacterBody2D

@export var player: Player

@export var SPEED: int = 300.0
@export var ACCELARATION: int = 500
@export var FRICTION: int = 400
@export var GRAVITY: float = 980.0

@export_category("Support Combat")
@export var attack_damage: int = 10
@export var skill_damage: int = 15
@export var detection_range: float = 220.0
@export var attack_range: float = 70.0
@export var attack_cooldown: float = 1.5
@export_range(0.0, 1.0) var skill_chance: float = 0.3

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

var target_enemy: Enemy = null
var attack_cooldown_timer: float = 0.0
var is_attacking: bool = false
var is_using_skill: bool = false
var retarget_time: float = 0.0
const RETARGET_DELAY: float = 0.2

func _ready() -> void:
	navigation_agent_2d.path_desired_distance = 200.0
	navigation_agent_2d.target_desired_distance = 50.0
	navigation_agent_2d.path_max_distance = 200.0

func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 60 == 0:
		print("Enemies found: ", get_tree().get_nodes_in_group("enemies").size())
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	attack_cooldown_timer -= delta
	if attack_cooldown_timer < 0.0:
		attack_cooldown_timer = 0.0
	
	if player == null or not is_instance_valid(player) or not Global.playerAlive:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		move_and_slide()
		return
		
	retarget_time -= delta
	if retarget_time <= 0.0:
		find_target_enemy()
		retarget_time = RETARGET_DELAY
	
	if is_attacking:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		move_and_slide()
		return
	
	if target_enemy != null:
		var distance_to_enemy: float = global_position.distance_to(target_enemy.global_position)
		
		navigation_agent_2d.target_position = target_enemy.global_position
		change_direction(sign(target_enemy.global_position.x - global_position.x))
		
		if distance_to_enemy <= attack_range:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
			try_attack()
		else:
			follow_navigation(delta)
	else:
		navigation_agent_2d.target_position = player.global_position + Vector2(30,0)
		follow_navigation(delta)
		
	move_and_slide()
	
func follow_navigation(delta: float) -> void:
	if navigation_agent_2d.is_target_reached():
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		return
	
	var direction: Vector2 = (
		navigation_agent_2d.get_next_path_position() - global_position).normalized()
		
	change_direction(direction.x)
	velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELARATION * delta)
	
func find_target_enemy() -> void:
	target_enemy = null
	var closet_distance: float = detection_range
	
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		
		if enemy == null:
			continue
		
		if not is_instance_valid(enemy) or enemy.defeat:
			continue

		var distance_to_enemy: float = global_position.distance_to(enemy.global_position)
		
		if distance_to_enemy <= closet_distance:
			closet_distance = distance_to_enemy
			target_enemy = enemy
			
func try_attack() -> void:
	if is_attacking:
		return
		
	if attack_cooldown_timer > 0.0:
		return
	
	if target_enemy == null:
		return
		
	if not is_instance_valid(target_enemy) or target_enemy.defeat:
		return
	
	is_attacking = true
	
	var attack_target: Enemy = target_enemy
	
	if abs(attack_target.global_position.x -global_position.x) > 5.0:
		change_direction(sign(attack_target.global_position.x - global_position.x))
	
	if randf() < skill_chance:
		await  use_skill_a(attack_target)
	else:
		await  normal_attack(attack_target)
	
	is_attacking = false
	attack_cooldown_timer = attack_cooldown
		
func normal_attack(target: Enemy) -> void:
	print("Support Char Normal Attack start.")
	#modulate = Color.GREEN
	#Attack anim here.
	await  get_tree().create_timer(0.2).timeout
	
	if is_instance_valid(target) and not target.defeat:
		target.take_damage(attack_damage)

func use_skill_a(target: Enemy) -> void:
	print("Support Char Normal Attack start.")
	is_using_skill = true
	#modulate = Color.YELLOW
	#Play anim here.
	await get_tree().create_timer(0.35).timeout
	
	var hit_count: int = 3
	
	for i in range(hit_count):
		if is_instance_valid(target) and not target.defeat:
			target.take_damage(skill_damage)
			
		await  get_tree().create_timer(0.2).timeout
		

func change_direction(direction: float) -> void:
	if sign(direction) == -1:
		sprite_2d.flip_h = false
	elif sign(direction) == 1:
		sprite_2d.flip_h = true
