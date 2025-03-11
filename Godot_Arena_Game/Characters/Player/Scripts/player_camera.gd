# player_camera.gd
# This script is attached to the player camera and updates its limits based on the level's tilemap bounds.

class_name PlayerCamera extends Camera2D

func _ready():
	# Connect to the LevelManager signal to update camera limits.
	LevelManager.tilemap_bounds_changed.connect(_update_limits)
	_update_limits(LevelManager.current_tilemap_bounds)
	pass

func _update_limits(bounds: Array[Vector2]) -> void:
	# If no bounds are provided, do nothing.
	if bounds == []:
		return
	# Update camera limits based on the provided tilemap bounds.
	limit_left = int(bounds[0].x)
	limit_top = int(bounds[0].y)
	limit_right = int(bounds[1].x)
	limit_bottom = int(bounds[1].y)
	pass
