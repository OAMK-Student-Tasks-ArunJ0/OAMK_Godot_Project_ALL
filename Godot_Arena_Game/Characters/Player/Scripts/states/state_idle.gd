# state_idle.gd
# This state controls the player's idle behavior.
# The player remains stationary using the idle animation until movement input is detected.
# (Attack input is now handled by the Abilities script.)

class_name State_Idle extends State

@onready var walk: State = $"../Walk"
# Attack state is removed from here as attack is handled in Abilities.gd.

func enter() -> void:
	# Set the player's animation to idle.
	player.update_animation("idle")

func exit() -> void:
	pass

func process(_delta: float) -> State:
	# If any movement input is detected, transition to the walking state.
	if player.direction != Vector2.ZERO:
		return walk
	# Ensure the player's velocity is zero while idle.
	player.velocity = Vector2.ZERO
	return null

func physics(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	# Emit an interaction event when the interact button is pressed.
	if _event.is_action_pressed("interact"):
		PlayerManager.interact_pressed.emit()
	return null
