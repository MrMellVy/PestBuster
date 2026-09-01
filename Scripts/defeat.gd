extends State

func enter() -> void:
	super.enter()
	owner.velocity = Vector2.ZERO
	owner.set_physics_process(false)
	owner.set_process(false)
	
	owner.disable_damage()
	animation_player.stop()
	
	animation_player_2.play("defeated")
	animation_player.play("defeated")
func  boss_slained():
	animation_player.play("boss_slained")
