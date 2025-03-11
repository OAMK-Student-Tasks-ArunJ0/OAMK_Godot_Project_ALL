# state.gd
# Base class for player states. States control behavior such as idle, walk, attack, dash, etc.
# Specific states should extend this class and override the methods.

class_name State extends Node

## Static references for the player and state machine.
static var player: Player
static var state_machine: PlayerStateMachine

func _ready():
	pass

## Called once when the state is initialized.
func init() -> void:
	pass

## Called when the state is entered.
func enter() -> void:
	pass

## Called when the state is exited.
func exit() -> void:
	pass

## Process update; return a new state to transition to, or null to remain.
func process(_delta: float) -> State:
	return null

## Physics update; return a new state if needed.
func physics(_delta: float) -> State:
	return null

## Handle input events; return a new state if needed.
func handle_input(_event: InputEvent) -> State:
	return null
