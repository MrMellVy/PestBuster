extends State

var is_attacking: bool = false

func _enter_tree() -> void:
	randomize()

func enter():
	super.enter()
	owner.velocity = Vector2.ZERO
	is_attacking = true

	attack()
	
func attack():
	animation_player.play("attack")
	await animation_player.animation_finished
	is_attacking = false
	
	owner.is_dealing_damage = false

func exit() -> void:
	super.exit()
	is_attacking = false
	owner.is_dealing_damage = false
	
func transition() -> void:
	if owner.global_position.distance_to(player.global_position) > 150:
		get_parent().change_state("Follow")
	elif  not is_attacking:
		get_parent().change_state("Follow")
