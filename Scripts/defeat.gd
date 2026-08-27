extends State

func enter() -> void:
	super.enter()
	animation_player_2.play("defeated")
	animation_player.play("defeated")
func  boss_slained():
	animation_player.play("boss_slained")
