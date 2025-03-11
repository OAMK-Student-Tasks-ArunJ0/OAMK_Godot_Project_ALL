# enemy_state.gd
# Base class for enemy states.
# Specific enemy behaviors (idle, attack, chase, etc.) should extend this class and override the methods.

class_name EnemyState extends Node

# References to the enemy and its state machine.
var enemy: Enemy
var state_machine: EnemyStateMachine

# Called once to initialize the state.
func init() -> void:
	pass

# Called when the enemy enters this state.
func enter() -> void:
	pass

# Called when the enemy exits this state.
func exit() -> void:
	pass

# Called every frame; return a new state to transition, or null to remain.
func process(_delta: float) -> EnemyState:
	return null

# Called during physics updates; return a new state if needed.
func physics(_delta: float) -> EnemyState:
	return null
