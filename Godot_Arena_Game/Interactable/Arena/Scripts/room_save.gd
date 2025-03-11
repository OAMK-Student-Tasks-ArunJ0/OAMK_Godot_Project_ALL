# room_save.gd
# This node allows the player to save the game when interacting with a specific area (e.g., a save point).

class_name RoomSave extends Node2D

@export var interact_audio : AudioStream

@onready var interact_area: Area2D = $InteractArea2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	# Connect signals for the save area.
	interact_area.area_entered.connect(_on_area_enter)
	interact_area.area_exited.connect(_on_area_exit)
	pass

func object_interact() -> void:
	# Save the game when the player interacts.
	SaveManager.save_game()
	audio.stream = interact_audio
	audio.play()
	pass

func _on_area_enter(_a : Area2D) -> void:
	# Connect the interact signal when the player enters.
	PlayerManager.interact_pressed.connect(object_interact)

func _on_area_exit(_a : Area2D) -> void:
	# Disconnect the interact signal when the player exits.
	PlayerManager.interact_pressed.disconnect(object_interact)
