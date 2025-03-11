# player_spawn.gd
# This script handles the initial spawning of the player.
# It ensures that the player is positioned at the correct spawn point when the level is loaded.
# The node is hidden in-game, as it only serves as a positional marker.


extends Node2D

func _ready() -> void:
	# Hide the spawn point since it's only used for positioning.
	visible = false
	# If the player has not yet been spawned, position them at this node's location.
	if PlayerManager.player_spawned == false:
		PlayerManager.set_player_position(global_position)
		PlayerManager.player_spawned = true
