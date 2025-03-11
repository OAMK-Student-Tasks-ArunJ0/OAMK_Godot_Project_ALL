# global_audio_manager.gd
# This script manages the audio for music in the game.
# It handles creating audio players, playing music with fade in/out transitions,
# and converting volume values between decibels and linear scale.

extends Node

# Number of AudioStreamPlayer nodes used for crossfading music.
var music_audio_player_count : int = 2

# Index of the currently active music player.
var current_music_player : int = 0

# Array holding the AudioStreamPlayer instances.
var music_players : Array[ AudioStreamPlayer ] = []

# The audio bus where the music is routed.
var music_bus : String = "Music"

# Duration (in seconds) for fading music in and out.
var music_fade_duration : float = 0.5

func _ready() -> void:
	# Load saved audio settings
	SaveManager.load_settings()
	# Ensure this node processes even when the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create the audio players based on the count
	for i in music_audio_player_count:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.bus = music_bus
		music_players.append(player)
		# Uncomment and adjust volume if needed
		# player.volume_db = -40

func play_music(_audio : AudioStream) -> void:
	# If the requested audio is already playing on the current player, do nothing.
	if _audio == music_players[current_music_player].stream:
		return
	
	# Switch to the next audio player for crossfading
	current_music_player += 1
	if current_music_player > 1:
		current_music_player = 0
	
	# Play the new audio on the current player with fade in
	var current_player : AudioStreamPlayer = music_players[current_music_player]
	current_player.stream = _audio
	play_and_fade_in(current_player)
	
	# Determine the old player (the one that was previously playing)
	var old_player = music_players[1]
	if current_music_player == 1:
		old_player = music_players[0]
	# Fade out the old music and stop the player
	fade_out_and_stop(old_player)

func play_and_fade_in(player : AudioStreamPlayer) -> void:
	# Start playing the audio from the beginning.
	player.play(0)
	# Create a tween for volume fade in
	var tween : Tween = create_tween()
	# Tween the player's volume from its current value to 0 dB (full volume)
	tween.tween_property(player, 'volume_db', 0, music_fade_duration)
	pass

func fade_out_and_stop(player : AudioStreamPlayer) -> void:
	# Create a tween for fading out the music.
	var tween : Tween = create_tween()
	# Tween the player's volume down to -40 dB (effectively silent)
	tween.tween_property(player, 'volume_db', -40, music_fade_duration)
	# Wait for the fade out to finish before stopping the player.
	await tween.finished
	player.stop()
	pass

# Utility functions to convert between decibel and linear volume values.

# Convert decibels to a linear scale.
func db_to_linear(db: float) -> float:
	return pow(10.0, db / 20.0)

# Convert a linear volume value to decibels.
func linear_to_db(linear: float) -> float:
	if linear < 0.0001:  # Avoid log of zero or negative values
		return -80.0  # Represents silence
	return 20.0 * (log(linear) / log(10.0))

# Get the current volume level (linear scale) for a given audio bus.
func get_bus_volume(bus_name: String) -> float:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))

# Set the volume for a given audio bus using a linear value.
func set_bus_volume(bus_name: String, value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
