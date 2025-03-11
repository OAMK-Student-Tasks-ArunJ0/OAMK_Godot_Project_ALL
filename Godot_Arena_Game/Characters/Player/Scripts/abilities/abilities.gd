# abilities.gd
# This script manages the player's special abilities, including dash, ranged, and melee attack abilities.
# It processes input for these abilities, instantiates projectiles, triggers state transitions, and sets cooldowns.

class_name Abilities extends Node

# Get the player's state machine.
@onready var state_machine: PlayerStateMachine = $"../StateMachine"

# Preload the projectile scenes.
const SHURIKEN = preload("res://Characters/Player/Scenes/shuriken.tscn")
const KNIFE = preload("res://Characters/Player/Scenes/knife.tscn")
const BOMB = preload("res://Characters/Player/Scenes/bomb.tscn")

enum Ranged_Weapon { SHURIKEN, KNIFE, BOMB }

# Dash ability settings.
@onready var dash_state: State_Dash = $"../StateMachine/Dash"
@export var dash_cooldown: float = 3.0
var can_dash: bool = true

# Ranged attack settings.
@export var ranged_cooldown: float = 1.0
var can_throw_ranged: bool = true

# Melee attack (attack state) settings.
@onready var attack_state: State_Attack = $"../StateMachine/Attack"
@export var attack_cooldown: float = 0.5
var can_attack: bool = true
var attack_timer: float = 0.0

# Hold instances of active projectiles (if any).
var knife_instance: Knife = null
var bomb_instance: Bomb = null
var shuriken_instance: Shuriken = null

var player: Player

# Timers for dash and ranged abilities.
var dash_timer: float = 0.0
var ranged_timer: float = 0.0

func _ready() -> void:
	# Cache the player reference from the player manager.
	player = PlayerManager.player

func _unhandled_input(event: InputEvent) -> void:
	# Process ability input only if the player is not stunned or dead.
	if player.abilities_allowed == true:
		if event.is_action_pressed("attack"):
			attack_ability()
		if event.is_action_pressed("ranged_attack"):
			# Select the ability based on the equipped ranged weapon.
			if player.ranged_weapon == "shuriken":
				shuriken_ability()
			elif player.ranged_weapon == "knife":
				knife_ability()
			elif player.ranged_weapon == "bomb":
				bomb_ability()
		if event.is_action_pressed("dash"):
			if player.dash_unlocked:
				dash_ability()

func attack_ability() -> void:
	# Trigger melee attack if not on cooldown.
	if not can_attack:
		return  # Still cooling down.
	# Switch to the attack state.
	state_machine.change_state(attack_state)
	# Start the attack cooldown.
	can_attack = false
	attack_timer = attack_cooldown
	var timer = get_tree().create_timer(attack_cooldown)
	timer.timeout.connect(func():
		can_attack = true
		attack_timer = 0.0
	)

func dash_ability() -> void:
	# Execute dash ability if available.
	if not can_dash:
		return
	state_machine.change_state(dash_state)
	# Use helper function to set dash cooldown.
	cooldown_funtion("dash", dash_cooldown)

func shuriken_ability() -> void:
	# Only allow one shuriken at a time.
	if shuriken_instance != null:
		return
	var _s = SHURIKEN.instantiate() as Shuriken
	# Add the projectile next to the player.
	player.add_sibling(_s)
	_s.global_position = player.global_position
	# Use player input for throw direction; if none, default to the current facing.
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	_s.throw(throw_direction)
	shuriken_instance = _s

func knife_ability() -> void:
	# Check if ranged ability is off cooldown.
	if not can_throw_ranged:
		return
	var _k = KNIFE.instantiate() as Knife
	player.add_sibling(_k)
	_k.global_position = player.global_position
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	_k.throw(throw_direction)
	knife_instance = _k
	cooldown_funtion("ranged", ranged_cooldown)

func bomb_ability() -> void:
	# Check if ranged ability is off cooldown.
	if not can_throw_ranged:
		return
	var _b = BOMB.instantiate() as Bomb
	player.add_sibling(_b)
	_b.global_position = player.global_position
	var throw_direction = player.direction
	if throw_direction == Vector2.ZERO:
		throw_direction = player.cardinal_direction
	_b.throw(throw_direction)
	bomb_instance = _b
	# Bomb ability uses a longer cooldown.
	cooldown_funtion("ranged", (ranged_cooldown * 3))

func cooldown_funtion(cooldown_type: String, cooldown: float) -> void:
	# Set cooldown flags and timers based on the ability type.
	if cooldown_type == "dash":
		can_dash = false
		dash_timer = cooldown
	elif cooldown_type == "ranged":
		can_throw_ranged = false
		ranged_timer = cooldown
	
	# Create a timer and reset the ability flag when the cooldown expires.
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
	# Decrement cooldown timers each frame.
	if dash_timer > 0:
		dash_timer = max(0, dash_timer - delta)
	if ranged_timer > 0:
		ranged_timer = max(0, ranged_timer - delta)
	if attack_timer > 0:
		attack_timer = max(0, attack_timer - delta)
