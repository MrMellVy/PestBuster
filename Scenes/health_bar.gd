extends ProgressBar

var enemy_parent

func _ready() -> void:
	enemy_parent = get_parent()
	
	if enemy_parent != null and "health_max" in enemy_parent:
		self.max_value = enemy_parent.health_max
	
func _process(_delta: float) -> void:
	if enemy_parent != null and "health" in enemy_parent:
		self.value = enemy_parent.health
		
		if enemy_parent.health == enemy_parent.health_max or enemy_parent.health <= enemy_parent.health_min:
			self.visible = false
		else:
			self.visible = true
