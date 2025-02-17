class_name EnemyStateStun extends EnemyState

@export var anim_name : String = "stun"
@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10.0

@export_category("AI")
@export var next_state : EnemyState

var _damage_position : Vector2
var _direction : Vector2
var _animation_finished : bool = false

# Initialization
func init() -> void:
	enemy.enemy_damaged.connect(_on_enemy_damaged)
	pass

# Enter the state
func enter() -> void:
	enemy.invulnerable = true
	_animation_finished = false

	# Calculate knockback direction
	_direction = enemy.global_position.direction_to(_damage_position)
	enemy.set_direction(_direction)
	enemy.velocity = _direction * -knockback_speed

	# Play stun animation
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	pass

# Exit the state
func exit() -> void:
	enemy.invulnerable = false
	enemy.velocity = Vector2.ZERO  # Clear velocity after stun
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	pass

# Process the state
func process(_delta: float) -> EnemyState:
	if _animation_finished:
		return next_state  # Transition to next state
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta  # Decelerate knockback
	return null

# Handle physics (if needed)
func physics(_delta: float) -> EnemyState:
	return null

# Handle damage to the enemy
func _on_enemy_damaged(hurt_box: HurtBox) -> void:
	_damage_position = hurt_box.global_position
	state_machine.change_state(self)
	pass

# Handle animation finished
func _on_animation_finished(_a: String) -> void:
	_animation_finished = true
	pass
