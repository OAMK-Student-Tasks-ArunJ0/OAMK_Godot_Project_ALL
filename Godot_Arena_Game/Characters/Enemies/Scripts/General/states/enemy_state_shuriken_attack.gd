class_name EnemyStateShurikenAttack extends EnemyState

const SHURIKEN = preload("res://Characters/Enemies/Scenes/Function Scenes/enemy_shuriken.tscn")

@export var anim_name: String = "ranged_attack"
@export var attack_anim_dur: float = 0.5
@export_category("AI")
@export var next_state: EnemyState

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var animation_finished: bool = false
var attack_timer: float = 0.0

func enter() -> void:
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	
	# Calculate direction to player
	var throw_direction = enemy.global_position.direction_to(PlayerManager.player.global_position)
	if throw_direction == Vector2.ZERO:
		throw_direction = enemy.direction
	
	# Create and throw shuriken
	var enemy_shuriken = SHURIKEN.instantiate() as EnemyShuriken
	enemy.add_sibling(enemy_shuriken)
	enemy_shuriken.global_position = enemy.global_position
	enemy_shuriken.throw(throw_direction.normalized())
	
	# Set the attack timer
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

func physics(_delta: float) -> EnemyState:
	return null
