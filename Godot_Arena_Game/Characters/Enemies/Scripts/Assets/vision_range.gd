# vision_range.gd
# This Area2D node represents an enemy's field of vision.
# It emits signals when the player enters or exits the range.
# It also adjusts its rotation based on the enemy's direction.

class_name VisionRange extends Area2D

signal player_entered()
signal player_exited()

func _ready() -> void:
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)
	
	# If the parent is an enemy, connect to its direction_changed signal.
	var parent_type = get_parent()
	if parent_type is Enemy:
		parent_type.direction_changed.connect(_on_direction_change)

func _on_body_enter(_body: Node2D) -> void:
	if _body is Player:
		player_entered.emit()
	pass

func _on_body_exit(_body: Node2D) -> void:
	if _body is Player:
		player_exited.emit()
	pass

func _on_direction_change(_changed_direction: Vector2) -> void:
	# Rotate the vision range based on the enemy's facing direction.
	match _changed_direction:
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
