# abilities.gd
class_name Abilities extends Node

@onready var state_machine: PlayerStateMachine = $"../StateMachine"

const SHURIKEN = preload("res://Characters/Player/Scenes/shuriken.tscn")
const KNIFE = preload("res://Characters/Player/Scenes/knife.tscn")  # Add the Knife scene

enum Ranged_Weapon { SHURIKEN, KNIFE }
var selected_ranged_weapon = Ranged_Weapon.KNIFE

# Dash
@onready var dash_state : State_Dash = $"../StateMachine/Dash"
@export var dash_cooldown : float = 3.0
var can_dash : bool = true

@export var knife_cooldown : float = 1.0
var can_throw_knife : bool = true
var knife_instance : Knife = null  # Add Knife instance

var shuriken_instance : Shuriken = null

var player : Player

func _ready() -> void:
	# Player reference
	player = PlayerManager.player

func _unhandled_input(event: InputEvent) -> void:
	if state_machine.current_state != State_Stun or state_machine.current_state != State_Death:
		if event.is_action_pressed("ranged_attack"):
			if selected_ranged_weapon == Ranged_Weapon.SHURIKEN:
				shuriken_ability()
			elif selected_ranged_weapon == Ranged_Weapon.KNIFE:  # Add Knife ability
				knife_ability()

		if event.is_action_pressed("dash"):
			dash_ability()

func shuriken_ability() -> void:
	if shuriken_instance != null:
		return
	
	var _s = SHURIKEN.instantiate() as Shuriken
	player.add_sibling(_s)
	_s.global_position = player.global_position
	
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	_s.throw(throw_direction)
	shuriken_instance = _s

func knife_ability() -> void:
	if can_throw_knife == false:
		return
	
	var _k = KNIFE.instantiate() as Knife
	player.add_sibling(_k)
	_k.global_position = player.global_position  # Ensure this is correct
	
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	_k.throw(throw_direction)
	knife_instance = _k
	
	cooldown_funtion( "knife", knife_cooldown )

func dash_ability() -> void:
	if not can_dash:
		return

	# Switch to dash
	player.state_machine.change_state(dash_state)

	# Start cooldown
	cooldown_funtion( "dash", dash_cooldown)

func cooldown_funtion( cooldown_type : String, cooldown: float) -> void:
	if cooldown_type == "dash":
		can_dash = false
	elif cooldown_type == "knife":
		can_throw_knife = false
	
	var cd_timer = get_tree().create_timer(cooldown)
	cd_timer.timeout.connect(func():
		if cooldown_type == "dash":
			can_dash = true
		elif cooldown_type == "knife":
			can_throw_knife = true
	)
