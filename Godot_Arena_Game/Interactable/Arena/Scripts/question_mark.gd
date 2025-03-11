# question_mark.gd
# Displays a question mark icon that, when interacted with, shows a message to the player.

class_name QuestionMark extends Node2D

@export var interact_audio : AudioStream

# (Optional) Uncomment and assign an audio node if needed.
# @onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var interact_area: Area2D = $InteractArea2D

@export var hud_message : String = "#no_message"
@export var hud_message_time : float = 2.0

func _ready() -> void:
	# Connect the interaction area signals.
	interact_area.area_entered.connect(_on_area_enter)
	interact_area.area_exited.connect(_on_area_exit)
	pass

func object_interact() -> void:
	# Emit a HUD message when interacted with.
	SaveManager.new_hud_message.emit(hud_message, 2.0)
	# Optionally, play an interaction sound.
	# audio.stream = interact_audio
	# audio.play()
	pass

func _on_area_enter(_a : Area2D) -> void:
	# Connect the player's interact signal to trigger the interaction.
	PlayerManager.interact_pressed.connect(object_interact)

func _on_area_exit(_a : Area2D) -> void:
	# Disconnect the interaction signal when the player leaves.
	PlayerManager.interact_pressed.disconnect(object_interact)
