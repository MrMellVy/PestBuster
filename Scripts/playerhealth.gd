extends ProgressBar

var parent
var max_value_amount
var min_value_amount

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	if Global.playerBody != null:
		self.max_value = Global.playerBody.health_max
		self.value = Global.playerBody.health
		
		if Global.playerBody.health == Global.playerBody.health_max or Global.playerBody.health <= Global.playerBody.health_min:
			self.visible = false
		else:
			self.visible = true
