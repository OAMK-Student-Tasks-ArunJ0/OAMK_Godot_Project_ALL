# health_bar.gd
# Displays a single health segment using a sprite frame that represents its value.

class_name HealthBar extends Control

@onready var sprite: Sprite2D = $Sprite2D

# The current value of this health bar (typically 0, 1, or 2).
var value : int = 2 :
	set(_value):
		value = _value
		update_sprite()

func update_sprite() -> void:
	# Update the sprite frame to match the current health value.
	sprite.frame = value
