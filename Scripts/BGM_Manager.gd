extends AudioStreamPlayer

@onready var dummy_player = AudioStreamPlayer.new()
var fading = false
var crossfade_time: float = 5.0
var fading_onstart: bool = true 

func _ready() -> void:
    add_child(dummy_player)
    stream = load("res://Assets/Audio/Musics/cyber_runner.ogg")
    volume_db = -80.0
    play()

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
func play_BGM(BGM_name) -> void:
    dummy_player.stream = load("res://Assets/Audio/Musics/" + BGM_name + ".ogg")
    dummy_player.volume_db = -60
    dummy_player.play()
    fading = true
