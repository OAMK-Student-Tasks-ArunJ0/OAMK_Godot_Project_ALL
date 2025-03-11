# enemy_state_idle_walk.gd
# This state allows an enemy to move slowly in a random direction when idle.
# It attempts to select a valid direction (i.e. one that doesn’t lead to an immediate collision)
# and moves for a set number of animation cycles before transitioning.

class_name EnemyStateIdleWalk extends EnemyState

@export var anim_name: String = "walk"
@export var idlewalk_speed: float = 20.0

@export_category("AI")
@export var state_animation_duration: float = 0.9
@export var state_cycles_min: int = 1
@export var state_cycles_max: int = 3
@export var next_state: EnemyState

var _timer: float = 0.0
var _direction: Vector2

func init() -> void:
	pass

func enter() -> void:
	# Determine a random duration for this walk state.
	_timer = randi_range(state_cycles_min, state_cycles_max) * state_animation_duration
	
	# Attempt to choose a valid direction (up, right, down, or left).
	var tries = 4
	while tries > 0:
		var rand = randi_range(0, 3)
		_direction = enemy.DIR_4[rand]
		
		# Predict movement to check for collisions (test-only move).
		var test_motion = _direction * idlewalk_speed * state_animation_duration
		var collision = enemy.move_and_collide(test_motion, true)
		
		if not collision:
			break
		tries -= 1
	
	# Set enemy movement and update animation.
	enemy.velocity = _direction * idlewalk_speed
	enemy.set_direction(_direction)
	enemy.update_animation(anim_name)

func exit() -> void:
	pass

func process(_delta: float) -> EnemyState:
	_timer -= _delta
	if _timer < 0:
		return next_state
	return null
