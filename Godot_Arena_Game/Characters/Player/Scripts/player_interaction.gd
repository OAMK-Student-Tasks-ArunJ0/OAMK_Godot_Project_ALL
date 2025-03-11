# player_interaction.gd
# This script handles the player's interaction indicator.
# It listens for changes in the player's direction and updates the node's rotation accordingly.

class_name PlayerInteractions extends Node2D

@onready var player: Player = $".."

func _ready():
	# Connect to the player's direction_changed signal.
	player.direction_changed.connect(_update_direction)
	pass

func _update_direction(new_direction: Vector2) -> void:
	# Rotate this node to visually represent the player's facing direction.
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90
		_:
			rotation_degrees = 0
	pass
