# global_level_manager.gd
# This script handles level loading, transitions, and notifying other nodes about level changes.
# It emits signals to indicate when a level load starts, completes, or when the tilemap bounds change.

extends Node

# Signals for level loading events.
signal level_load_started
signal level_loaded
signal tilemap_bounds_changed(bounds : Array[Vector2])

# Holds the current bounds of the tilemap.
var current_tilemap_bounds : Array[Vector2]
# Name of the transition effect to use between levels.
var target_transition : String
# Offset to apply when transitioning levels.
var position_offset : Vector2
# Flag to allow or disallow level transitions.
var can_transition = true

func _ready() -> void:
	# Wait one frame to ensure everything is initialized, then emit the level_loaded signal.
	await get_tree().process_frame
	level_loaded.emit()

# Update the current tilemap bounds and notify listeners.
func change_tilemap_bounds(bounds : Array[Vector2]) -> void:
	current_tilemap_bounds = bounds
	tilemap_bounds_changed.emit(bounds)

# Load a new level (scene) with transition effects.
func load_new_level(
		level_path : String,
		_target_transition : String,
		_position_offset : Vector2
) -> void:
	# Pause the game tree while transitioning.
	get_tree().paused = true
	target_transition = _target_transition
	position_offset = _position_offset
	
	# Fade out the current scene before changing
	await SceneTransition.fade_out()
	
	# Emit signal indicating level load has started.
	level_load_started.emit()
	
	# Wait for a frame to ensure the transition takes effect.
	await get_tree().process_frame
	
	# Change the scene to the new level
	get_tree().change_scene_to_file(level_path)
	
	# Fade in the new level after the scene change.
	await SceneTransition.fade_in()
	
	# Resume the game
	get_tree().paused = false
	
	# Wait one frame and emit the level_loaded signal.
	await get_tree().process_frame
	level_loaded.emit()
	
	pass
