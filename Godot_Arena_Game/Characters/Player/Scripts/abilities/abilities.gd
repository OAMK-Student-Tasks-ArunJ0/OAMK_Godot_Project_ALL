# abilities.gd
class_name Abilities extends Node

@onready var state_machine: PlayerStateMachine = $"../StateMachine"

const SHURIKEN = preload("res://Characters/Player/Scenes/shuriken.tscn")
const KNIFE = preload("res://Characters/Player/Scenes/knife.tscn")  # Add the Knife scene
const BOMB = preload("res://Characters/Player/Scenes/bomb.tscn")

enum Ranged_Weapon { SHURIKEN, KNIFE, BOMB }

# Dash
@onready var dash_state : State_Dash = $"../StateMachine/Dash"
@export var dash_cooldown : float = 3.0
var can_dash : bool = true

@export var ranged_cooldown : float = 1.0

var can_throw_ranged : bool = true

var knife_instance : Knife = null  # Add Knife instance
var bomb_instance : Bomb = null
var shuriken_instance : Shuriken = null

var player : Player

var dash_timer: float = 0.0
var ranged_timer: float = 0.0

func _ready() -> void:
	# Player reference
	player = PlayerManager.player

func _unhandled_input(event: InputEvent) -> void:
	if state_machine.current_state != State_Stun or state_machine.current_state != State_Death:
		if event.is_action_pressed("ranged_attack"):
			if player.ranged_weapon == "shuriken":
				shuriken_ability()
			elif player.ranged_weapon == "knife":  # Add Knife ability
				knife_ability()
			elif player.ranged_weapon == "bomb":  # Add Knife ability
				bomb_ability()

		if event.is_action_pressed("dash"):
			dash_ability()

func dash_ability() -> void:
	if not can_dash:
		return

	# Switch to dash
	player.state_machine.change_state(dash_state)

	# Start cooldown
	cooldown_funtion( "dash", dash_cooldown)

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
	if can_throw_ranged == false:
		return
	
	var _k = KNIFE.instantiate() as Knife
	player.add_sibling(_k)
	_k.global_position = player.global_position  # Ensure this is correct
	
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	_k.throw(throw_direction)
	knife_instance = _k
	
	cooldown_funtion( "ranged", ranged_cooldown )

func bomb_ability() -> void:
	if can_throw_ranged == false:
		return
	
	var _b = BOMB.instantiate() as Bomb
	player.add_sibling(_b)
	_b.global_position = player.global_position  # Ensure this is correct
	
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	_b.throw(throw_direction)
	bomb_instance = _b
	
	cooldown_funtion( "ranged", (ranged_cooldown*3) )


func cooldown_funtion(cooldown_type: String, cooldown: float) -> void:
	if cooldown_type == "dash":
		can_dash = false
		dash_timer = cooldown
	elif cooldown_type == "ranged":
		can_throw_ranged = false
		ranged_timer = cooldown
	
	var timer = get_tree().create_timer(cooldown)
	timer.timeout.connect(func():
		if cooldown_type == "dash":
			can_dash = true
			dash_timer = 0.0
		elif cooldown_type == "ranged":
			can_throw_ranged = true
			ranged_timer = 0.0
	)

func _process(delta: float) -> void:
	# Update both timers if they're counting down
	if dash_timer > 0:
		dash_timer = max(0, dash_timer - delta)
	if ranged_timer > 0:
		ranged_timer = max(0, ranged_timer - delta)
