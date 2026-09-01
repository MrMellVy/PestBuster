extends CharacterBody2D

const SPEED = 10.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 980.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite = $AnimatedSprite2D
@onready var progress_bar = $UI/ProgressBar

var direction_x : float = 1.0
var direction: Vector2

@export var damage_to_deal: int = 30
var is_dealing_damage: bool = false
var has_dealt_damage: bool = false
var defeat: bool = false

var health := 100:
	set(value):
		health = value
		progress_bar.value = value
		if value <= 0:
			defeat = true
			progress_bar.visible = false
			find_child("FiniteStateMachine").change_state("Defeat")

func _ready() -> void:
	add_to_group("enemies")

func _process(_delta: float) -> void:
	direction = player.position - position
	if player.position.x < position.x :
		animated_sprite.flip_h = false
		direction_x = -1.0
	else:
		animated_sprite.flip_h = true
		direction_x = 1.0
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	Global.EnemyDamageAmount = damage_to_deal
	move_and_slide()

func _on_boss_hitbox_area_entered(area: Area2D) -> void:
	if area == Global.playerDamageZone:
		var damage = Global.playerDamageAmount
		take_damage(damage)

func enable_damage():
	is_dealing_damage = true
	has_dealt_damage = false
	
func disable_damage():
	is_dealing_damage = false

func take_damage(damage_amount: int):
	health -= damage_amount
	
	print("Boss took ", damage_amount, " damage! HP left: ", health)
