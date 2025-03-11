# level.gd
# This script represents an individual level in the game.
# It sets up the level's properties, such as y-sorting for proper layering,
# reparenting the player to the level for correct positioning,
# and playing the background music specific to this level.
# When a new level is loaded, the current level will free itself.

class_name Level extends Node2D

# The background music for this level.
@export var music : AudioStream

func _ready() -> void:
	# Enable y-sorting for proper draw order.
	self.y_sort_enabled = true
	# Set this level as the new parent for the player.
	PlayerManager.set_as_parent(self)
	# Connect to the level load signal to free this level when a new level loads.
	LevelManager.level_load_started.connect(_free_level)
	# Play the level's background music.
	AudioManager.play_music(music)

# Called when a new level starts loading, freeing this level from the scene.
func _free_level() -> void:
	# Remove the player from this level.
	PlayerManager.unparent_player(self)
	# Queue this level for deletion.
	queue_free()
