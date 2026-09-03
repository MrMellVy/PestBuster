extends RichTextLabel


var default_text = "CURRENT ZONE: "

func _process(delta: float) -> void:
	var text = str(default_text, str(Global.current_wave))
	self.text = (text)
