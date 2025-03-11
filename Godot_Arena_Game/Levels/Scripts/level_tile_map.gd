# level_tile_map.gd
# This script manages the tilemap layer for a level.
# It calculates the bounds of the used portion of the tilemap and informs the LevelManager,
# ensuring that level boundaries are known for events like transitions.

class_name LevelTileMap extends TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# Calculate the tilemap bounds and update the LevelManager with these bounds.
	LevelManager.change_tilemap_bounds(_get_tilemap_bounds())
	pass

# Calculate and return the bounds of the tilemap in world coordinates.
func _get_tilemap_bounds() -> Array[Vector2]:
	var bounds : Array[Vector2] = []
	# First corner: the top-left of the used rectangle scaled by the rendering quadrant size.
	bounds.append(Vector2(get_used_rect().position * rendering_quadrant_size))
	# Second corner: the bottom-right of the used rectangle scaled by the rendering quadrant size.
	bounds.append(Vector2(get_used_rect().end * rendering_quadrant_size))
	return bounds
