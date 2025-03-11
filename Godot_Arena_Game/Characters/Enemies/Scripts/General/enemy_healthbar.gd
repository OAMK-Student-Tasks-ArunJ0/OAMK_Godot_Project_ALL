# enemy_healthbar.gd
# This node displays the enemy's health as a bar.
# It updates its width and color based on the enemy's current health percentage.

class_name EnemyHealthBar extends Node2D

@onready var background: ColorRect = $Background
@onready var foreground: ColorRect = $Foreground

@export var health_bar_x = 50  # Full width of the health bar

# Initialize the health bar's width.
func initialize() -> void:
	foreground.size.x = health_bar_x  # Set the foreground (current health) to full width
	background.size.x = health_bar_x  # Set the background (max health)

# Update the health bar based on current and maximum health.
func update_health(current_health: int, max_health: int) -> void:
	var health_percentage = current_health / float(max_health)
	# Scale the foreground width according to the health percentage.
	foreground.size.x = background.size.x * health_percentage

	# Change color based on health: green (high), yellow (medium), red (low).
	if health_percentage < 0.3:
		foreground.color = Color(1, 0, 0)
	elif health_percentage < 0.7:
		foreground.color = Color(1, 1, 0)
	else:
		foreground.color = Color(0, 1, 0)
