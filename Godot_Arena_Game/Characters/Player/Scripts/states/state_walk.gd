# state_walk.gd
# This state handles the player's walking behavior.
# The player moves according to input and transitions back to idle when no input is given.
# (Attack input is now managed by the Abilities script.)

class_name State_Walk extends State

@export var move_speed: float = 100.0

@onready var idle: State = $"../Idle"
# Attack state is omitted since melee attack is now triggered by Abilities.gd.

func enter() -> void:
	# Set the player's animation to walking.
	player.update_animation("walk")

func exit() -> void:
	pass

func process(_delta: float) -> State:
	# Transition to idle if no movement input is present.
	if player.direction == Vector2.ZERO:
		return idle
	
	# Update the player's velocity based on the movement input and configured speed.
	player.velocity = player.direction * move_speed
	
	# Update the player's facing direction; if changed, refresh the walking animation.
	if player.set_direction():
		player.update_animation("walk")
	return null

func physics(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	# Emit an interaction event if the interact button is pressed.
	if _event.is_action_pressed("interact"):
		PlayerManager.interact_pressed.emit()
	return null
