extends RichTextLabel


var default_text = "PREVIOUS RD: "
var default_text2 = "(PLACEHOLDER)"

func _process(delta: float) -> void:
	var text = str(default_text, str(Global.previous_score), str(default_text2))
	self.text = (text)
