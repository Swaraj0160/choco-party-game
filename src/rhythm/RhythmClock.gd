extends Node

signal beat_hit(beat_number)
signal measure_hit(measure_number)

var bpm: float = 120.0
var offset_ms: float = 0.0
var is_playing: bool = false

var current_beat: int = -1
var current_measure: int = -1
var beats_per_measure: int = 4

var audio_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

func load_song(stream: AudioStream, song_bpm: float, song_offset_ms: float = 0.0):
	audio_player.stream = stream
	bpm = song_bpm
	offset_ms = song_offset_ms
	
func start():
	is_playing = true
	audio_player.play()
	current_beat = -1
	current_measure = -1
	
func stop():
	is_playing = false
	audio_player.stop()

func get_song_position() -> float:
	if not is_playing:
		return 0.0
	
	var time_sec = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	time_sec -= AudioServer.get_output_latency()
	
	return time_sec

func get_beat_duration() -> float:
	return 60.0 / bpm

func _process(_delta):
	if not is_playing:
		return
		
	var pos = get_song_position() - (offset_ms / 1000.0)
	if pos < 0:
		return
		
	var beat_duration = get_beat_duration()
	var beat_f = pos / beat_duration
	var beat_i = int(floor(beat_f))
	
	if beat_i > current_beat:
		current_beat = beat_i
		beat_hit.emit(current_beat)
		
		var measure_i = current_beat / beats_per_measure
		if measure_i > current_measure:
			current_measure = measure_i
			measure_hit.emit(current_measure)
