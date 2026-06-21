extends AudioStreamPlayer

@onready var dummy_player = AudioStreamPlayer.new()
@onready var sfx_player = AudioStreamPlayer.new()
var fading = false
var crossfade_time: float = 5.0
var fading_onstart: bool = true 

func _ready() -> void:
	add_child(dummy_player)
	add_child(sfx_player)
	volume_db = -80.0
	play()

func play_defeated():
	stop()
	dummy_player.stop()
	sfx_player.stream = load("res://Assets/Audio/SFX/Gameovertheme.wav")
	sfx_player.volume_db = 0.0
	sfx_player.play()
	
func _process(delta: float) -> void:
	if fading_onstart:
		#volume_db += 30*delta #simple math
		var fade_speed_onstart = 80.0 / crossfade_time
		volume_db += fade_speed_onstart * delta
		if volume_db >= 0.0:
			volume_db = 0
			fading_onstart = false
		
	if fading:
		var fade_speed = 60.0 / crossfade_time
		volume_db -= fade_speed * delta
		dummy_player.volume_db += fade_speed * delta

		if dummy_player.volume_db >= 0:
			volume_db = 0
			dummy_player.volume_db = -60
			
			stream = dummy_player.stream
			play(dummy_player.get_playback_position())
			
			dummy_player.stop()
			fading = false
			
var retry_themes = {
	"Retry": {
		"intro": "res://Assets/Audio/Musics/Original/Gameovertheme_2.ogg",
		"loop": "res://Assets/Audio/Musics/Original/Gameovertheme_2ExtLoop.ogg"
	}
}
var next_loop_path: String = ""
	

func play_retry_music(theme_name: String = "Retry"):
	sfx_player.stop() 
	next_loop_path = retry_themes[theme_name]["loop"]
	if not sfx_player.finished.is_connected(_on_intro_finished):
		sfx_player.finished.connect(_on_intro_finished)
	sfx_player.stream = load(retry_themes[theme_name]["intro"])
	sfx_player.play()
	
#This func for looping the song if you have a second song that just only for the loop part.
func _on_intro_finished():
	sfx_player.finished.disconnect(_on_intro_finished)
	stream = load(next_loop_path)
	volume_db = 0.0
	play()

func play_BGM(BGM_name) -> void:
	dummy_player.stream = load("res://Assets/Audio/Musics/" + BGM_name + ".ogg")
	dummy_player.volume_db = -60
	dummy_player.play()
	fading = true
