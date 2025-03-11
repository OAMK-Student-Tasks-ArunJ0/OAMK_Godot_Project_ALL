# player_state_machine.gd
# This state machine controls the player's current behavior (e.g., idle, walking, attacking, dashing).
# It changes states based on input, physics, or events.

class_name PlayerStateMachine extends Node

var states: Array[State]
var prev_state: State
var current_state: State

func _ready():
	# Disable processing until the state machine is initialized.
	process_mode = Node.PROCESS_MODE_DISABLED
	pass

func _process(delta):
	# Process current state logic and update state if needed.
	change_state(current_state.process(delta))
	pass

func _physics_process(delta):
	# Process physics updates in the current state.
	change_state(current_state.physics(delta))
	pass

func _unhandled_input(event):
	# Forward unhandled input to the current state.
	change_state(current_state.handle_input(event))
	pass

func Initialize(_player: Player) -> void:
	# Collect all child nodes that extend State.
	states = []
	for c in get_children():
		if c is State:
			states.append(c)
	
	# If no states found, do nothing.
	if states.size() == 0:
		return
	
	# Set up the first state with references to the player and the state machine.
	states[0].player = _player
	states[0].state_machine = self
	
	for state in states:
		state.init()
	
	# Begin with the first state.
	change_state(states[0])
	# Allow processing to occur.
	process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state: State) -> void:
	# If the new state is null or the same as the current, do nothing.
	if new_state == null or new_state == current_state:
		return
	
	# Call exit on the current state if one exists.
	if current_state:
		current_state.exit()
	
	prev_state = current_state
	current_state = new_state
	# Call enter on the new state.
	current_state.enter()
