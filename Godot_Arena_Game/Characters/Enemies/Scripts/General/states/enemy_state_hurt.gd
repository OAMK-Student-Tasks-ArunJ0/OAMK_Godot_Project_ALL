# enemy_state_hurt.gd
# This state handles when an enemy is hurt after taking damage.
# It applies knockback and temporary invulnerability, then transitions to the next state.

class_name EnemyStateHurt extends EnemyState

@export var anim_name: String = "hurt"
@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0

@export_category("AI")
@export var next_state: EnemyState  # State to transition to after hurt

var _damage_position: Vector2
var _direction: Vector2
var _animation_finished: bool = false

# Optional: a separate animation player for boss enemies.
@export var boss_animation_player: AnimationPlayer = null

func init() -> void:
	# Connect to the enemy's damage signal to trigger hurt.
	enemy.enemy_damaged.connect(_on_enemy_damaged)
	pass

func enter() -> void:
	# Set enemy invulnerability during hurt.
	enemy.invulnerable = true
	_animation_finished = false

	# Calculate knockback direction based on damage position.
	_direction = enemy.global_position.direction_to(_damage_position)
	enemy.set_direction(_direction)
	enemy.velocity = _direction * -knockback_speed

	# Play the hurt/hurt animation.
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	pass

func exit() -> void:
	# Restore vulnerability and clear velocity.
	enemy.invulnerable = false
	enemy.velocity = Vector2.ZERO
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	pass

func process(_delta: float) -> EnemyState:
	# Gradually decelerate the knockback.
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	# Transition to the next state once the animation is finished.
	if _animation_finished:
		return next_state
	return null

func _on_enemy_damaged(hurt_box: HurtBox) -> void:
	if boss_animation_player != null:
		boss_animation_player.play(anim_name)
	else:
		_damage_position = hurt_box.global_position
		state_machine.change_state(self)
	pass

func _on_animation_finished(_a: String) -> void:
	_animation_finished = true
	pass
