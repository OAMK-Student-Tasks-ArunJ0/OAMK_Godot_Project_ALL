# enemy_state_machine.gd
# This state machine manages the behavior of an enemy.
# It collects enemy state nodes, initializes them, and changes states based on updates.

class_name EnemyStateMachine extends Node

var states: Array[EnemyState]
var prev_state: EnemyState
var current_state: EnemyState

func _ready() -> void:
	# Disable processing until initialization.
	process_mode = Node.PROCESS_MODE_DISABLED
	pass

func _process(delta):
	# Process the current state's logic and transition if needed.
	change_state(current_state.process(delta))
	pass

func _physics_process(delta):
	# Process physics updates in the current state.
	change_state(current_state.physics(delta))
	pass

func initialize(_enemy: Enemy) -> void:
	# Gather all children that are EnemyState nodes.
	states = []
	for c in get_children():
		if c is EnemyState:
			states.append(c)
	
	# Initialize each state with a reference to the enemy and state machine.
	for s in states:
		s.enemy = _enemy
		s.state_machine = self
		s.init()
	
	# If any states exist, begin with the first one and enable processing.
	if states.size() > 0:
		change_state(states[0])
		process_mode = Node.PROCESS_MODE_INHERIT

func change_state(new_state: EnemyState) -> void:
	# Transition to a new state if it's different from the current one.
	if new_state == null or new_state == current_state:
		return
	
	if current_state:
		current_state.exit()
	
	prev_state = current_state
	current_state = new_state
	current_state.enter()
