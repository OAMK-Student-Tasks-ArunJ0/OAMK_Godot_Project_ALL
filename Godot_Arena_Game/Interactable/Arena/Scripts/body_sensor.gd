# body_sensor.gd
# This sensor tracks bodies entering and exiting its area, activating or deactivating accordingly.
# It also plays an activation or deactivation sound.

class_name BodySensor extends Node2D

signal activated
signal deactivated

# Tracks the number of bodies currently inside.
var bodies : int = 0
# Whether the sensor is active.
var is_active : bool = false

# Colors for debugging or visual feedback (if used).
var on_color = "00b06d"
var off_color = "ff4646"
var off_rect : Rect2

@onready var area_2d: Area2D = $Area2D
@onready var audio : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_activate : AudioStream = preload("res://Interactable/Arena/Sounds/lever-01.wav")
@onready var audio_deactivate : AudioStream = preload("res://Interactable/Arena/Sounds/lever-02.wav")

func _ready() -> void:
	# Connect area signals to monitor bodies entering and exiting.
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)

func _on_body_entered(_b : Node2D) -> void:
	# Increment the count when a body enters.
	bodies += 1
	check_is_activated()
	pass

func _on_body_exited(_b : Node2D) -> void:
	# Decrement the count when a body exits.
	bodies -= 1
	check_is_activated()
	pass

func check_is_activated() -> void:
	# Activate if at least one body is present and sensor was inactive.
	if bodies > 0 and not is_active:
		is_active = true
		play_audio(audio_activate)
		activated.emit()
	# Deactivate if no bodies are present and sensor was active.
	elif bodies <= 0 and is_active:
		is_active = false
		play_audio(audio_deactivate)
		deactivated.emit()
	pass

func play_audio(_stream : AudioStream) -> void:
	# Play the provided audio stream.
	audio.stream = _stream
	audio.play()
	pass
