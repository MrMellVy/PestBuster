extends HBoxContainer

var skills: Array
@onready var debug: Label = $"../Debug"

func _ready() -> void:
	skills = get_children()
	
	for i in get_child_count():
		skills[i].cast.connect(_casted)

		if i == 0:
			skills[i].change_key = "C"
		else:
			skills[i].change_key = str(i+1)

func _casted(skill_name):
	debug.text = skill_name
	
	var player = Global.playerBody
	if player == null:
		return
		
	match  skill_name:
		"SkillA":
			player.perform_skill_a()
		_:
			print("No skill assigned for: ", skill_name)
