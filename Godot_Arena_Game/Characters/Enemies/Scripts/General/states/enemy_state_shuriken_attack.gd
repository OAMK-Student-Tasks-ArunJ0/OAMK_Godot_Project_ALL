# enemy_state_shuriken_attack.gd
# This state allows an enemy to perform a ranged shuriken attack.
# It calculates a throw direction toward the player, instantiates a shuriken, and then waits for the animation to finish.

class_name EnemyStateShurikenAttack extends EnemyState

const SHURIKEN_STRONG = preload("res://Characters/Enemies/Scenes/Function Scenes/enemy_shuriken_strong.tscn")
const SHURIKEN_WEAK = preload("res://Characters/Enemies/Scenes/Function Scenes/enemy_shuriken_weak.tscn")

@export var shuriken_strength : String = "weak"

@export var anim_name: String = "ranged_attack"
@export var attack_anim_dur: float = 0.9

@export_category("AI")
@export var next_state: EnemyState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var animation_finished: bool = false
var attack_timer: float = 0.0
# Store the throw direction calculated at state entry.
var throw_direction: Vector2 = Vector2.ZERO

func enter() -> void:
	# Start the attack animation.
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	
	# Calculate the direction to the player.
	throw_direction = enemy.global_position.direction_to(PlayerManager.player.global_position)
	if throw_direction == Vector2.ZERO:
		throw_direction = enemy.direction
	
	# Instantiate and throw the shuriken.
	var enemy_shuriken : EnemyShuriken
	if shuriken_strength == "strong":
		enemy_shuriken = SHURIKEN_STRONG.instantiate() as EnemyShuriken
	else:
		enemy_shuriken = SHURIKEN_WEAK.instantiate() as EnemyShuriken
	enemy.add_sibling(enemy_shuriken)
	enemy_shuriken.global_position = enemy.global_position
	enemy_shuriken.throw(throw_direction.normalized())
	
	# Set the timer for the attack animation.
	attack_timer = attack_anim_dur

func exit() -> void:
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	animation_finished = false
	enemy.velocity = Vector2.ZERO

func process(delta: float) -> EnemyState:
	if animation_finished:
		return next_state
	
	attack_timer -= delta
	if attack_timer <= 0:
		return next_state
	
	return null

func _on_animation_finished(_anim_name: String) -> void:
	animation_finished = true
