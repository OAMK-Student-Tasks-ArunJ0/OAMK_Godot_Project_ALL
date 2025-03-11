# enemy_state_bomb_attack.gd
# This state allows an enemy to perform a ranged bomb attack.
# It delays the bomb throw until partway through the animation, then transitions to the next state.

class_name EnemyStateBombAttack extends EnemyState

const BOMB = preload("res://Characters/Enemies/Scenes/Function Scenes/enemy_bomb.tscn")

@export var anim_name: String = "ranged_attack"
@export var attack_anim_dur: float = 0.5
@export_category("AI")
@export var next_state: EnemyState
@export var bomb_throw_delay: float = 0.3  # Delay before throwing the bomb during the animation

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var animation_finished: bool = false
var attack_timer: float = 0.0
var throw_direction: Vector2 = Vector2.ZERO
var has_thrown: bool = false
var throw_timer: float = 0.0

func enter() -> void:
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	
	# Calculate the direction to the player.
	throw_direction = enemy.global_position.direction_to(PlayerManager.player.global_position)
	if throw_direction == Vector2.ZERO:
		throw_direction = enemy.direction
	
	# Reset state variables.
	attack_timer = attack_anim_dur
	has_thrown = false
	throw_timer = bomb_throw_delay

func exit() -> void:
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	animation_finished = false
	enemy.velocity = Vector2.ZERO

func process(delta: float) -> EnemyState:
	if animation_finished:
		return next_state
	
	attack_timer -= delta
	
	# Delay bomb throw until the throw timer elapses.
	if not has_thrown:
		throw_timer -= delta
		if throw_timer <= 0:
			throw_bomb()
			has_thrown = true
	
	if attack_timer <= 0:
		return next_state
	
	return null

func throw_bomb() -> void:
	# Instantiate and throw the bomb.
	var enemy_bomb = BOMB.instantiate() as EnemyBomb
	enemy.add_sibling(enemy_bomb)
	enemy_bomb.global_position = enemy.global_position
	# Slight randomness in the throw direction.
	var random_angle = randf_range(-0.1, 0.1)
	var randomized_direction = throw_direction.rotated(random_angle)
	enemy_bomb.throw(randomized_direction, enemy)
	
func _on_animation_finished(_anim_name: String) -> void:
	animation_finished = true
