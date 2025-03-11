# level_transition.gd
# This script defines a level transition area.
# When the player enters this Area2D and is close enough, it triggers a level change.
# The script supports configurable collision area size, snapping to a grid, and offset adjustments
# to properly position the player in the new level.

@tool
class_name LevelTransition extends Area2D

# Enumeration for the side of the level where the transition occurs.
enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

# The target level scene to load when the transition is activated.
@export_file("*.tscn") var level
# Name of the transition area, used by the LevelManager.
@export var target_transition_area : String = "LevelTransition"
# Determines if the player should be centered when transitioning.
@export var center_player : bool = false

@export_category("Collision Area Settings")
# The size multiplier for the collision area. Changing this updates the area via _update_area().
@export_range(1, 12, 1, "or_greater") var size : int = 2 :
	set(_v):
		size = _v
		_update_area()

# Which side of the level this transition area is on.
@export var side: SIDE = SIDE.LEFT :
	set(_v):
		side = _v
		_update_area()

# Option to snap the transition area's position to a 16x16 grid.
@export var snap_to_grid : bool = false :
	set(_v):
		_snap_to_grid()

# Cache the CollisionShape2D node for adjusting the collision area.
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Update the collision area based on exported properties.
	_update_area()
	
	# If running in the editor, stop further processing.
	if Engine.is_editor_hint():
		return
	
	# Temporarily disable monitoring during initial placement.
	monitoring = false
	# Position the player if this transition is the target.
	_place_player()
	
	# Wait until the level has finished loading.
	await LevelManager.level_loaded
	
	# Re-enable monitoring and connect the body_entered signal.
	monitoring = true
	body_entered.connect(_player_entered)
	pass

# Check if the player is within a 50 pixel distance from this transition.
func is_player_close() -> bool:
	var player_pos = PlayerManager.player.global_position
	var distance = global_position.distance_to(player_pos)
	return distance <= 50.0

# Called when a body enters the transition area.
func _player_entered(_p : Node2D) -> void:
	# If the body is the player and they are close enough, trigger the level change.
	if _p is Player and is_player_close():
		# Uncomment the next line for debugging purposes.
		# print("Player entered LevelTransition: ", name)
		LevelManager.load_new_level(level, target_transition_area, get_offset())
	pass

# Place the player at the transition's position plus any offset defined by the LevelManager.
func _place_player() -> void:
	# Only reposition if this transition area is the target for the level change.
	if name != LevelManager.target_transition:
		return
	PlayerManager.set_player_position(global_position + LevelManager.position_offset)

# Calculate the offset to apply to the player's position when transitioning.
func get_offset() -> Vector2:
	var offset : Vector2 = Vector2.ZERO
	var player_pos = PlayerManager.player.global_position
	
	# For left/right transitions, adjust x and optionally y offset.
	if side == SIDE.LEFT or side == SIDE.RIGHT:
		if center_player == true:
			offset.y = 0
		else:
			offset.y = player_pos.y - global_position.y
		offset.x = 16
		if side == SIDE.LEFT:
			offset.x *= -1
	else:
		# For top/bottom transitions, adjust y and optionally x offset.
		if center_player == true:
			offset.x = 0
		else:
			offset.x = player_pos.x - global_position.x
		offset.y = 16
		if side == SIDE.TOP:
			offset.y *= -1

	return offset

# Update the collision shape's size and position based on the transition side and size.
func _update_area() -> void:
	var new_rect : Vector2 = Vector2(32, 32)
	var new_position : Vector2 = Vector2.ZERO
	
	# Adjust the size and position based on which side the transition occurs.
	if side == SIDE.TOP:
		new_rect.x *= size
		new_position.y -= 16
	elif side == SIDE.BOTTOM:
		new_rect.x *= size
		new_position.y += 16
	elif side == SIDE.LEFT:
		new_rect.y *= size
		new_position.x -= 16
	elif side == SIDE.RIGHT:
		new_rect.y *= size
		new_position.x += 16
	
	# Ensure collision_shape is valid.
	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")
	
	# Update the collision shape's dimensions and position.
	collision_shape.shape.size = new_rect
	collision_shape.position = new_position

# Snap the transition area's position to a 16x16 grid.
func _snap_to_grid() -> void:
	position.x = round(position.x / 16) * 16
	position.y = round(position.y / 16) * 16
