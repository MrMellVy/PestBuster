extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	BgmManager.play_retry_music("Retry")
	$AnimationPlayer.play("Title")
