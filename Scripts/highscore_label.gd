extends RichTextLabel

var default_text = "HIGH SCORE: "
var default_text2 = ""

func _process(delta: float) -> void:
	var text = str(default_text, str(Global.high_score), str(default_text2))
	self.text = (text)
