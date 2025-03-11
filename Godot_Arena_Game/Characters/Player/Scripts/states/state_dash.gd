# state_dash.gd
# Handles the dash ability.
# Temporarily boosts the player's speed in their current facing direction, then transitions back to idle or walk.

class_name State_Dash
extends State

@export var dash_speed: float = 250.0
@export var dash_duration: float = 0.24
@export var dash_anim_name: String = "dash"

var _timer: float = 0.0
var _old_velocity: Vector2
var _dash_direction: Vector2

func init() -> void:
	# Initialization if needed.
	pass

func enter() -> void:
	# Save current velocity.
	_old_velocity = player.velocity
	# Use the player's current cardinal direction for the dash.
	_dash_direction = player.cardinal_direction
	# Set dash velocity.
	player.velocity = _dash_direction * dash_speed
	# Initialize the dash timer.
	_timer = dash_duration
	# Update to the dash animation.
	player.update_animation(dash_anim_name)
	# Make the player invulnerable for the dash duration.
	player.make_invulnerable(dash_duration)
	
func exit() -> void:
	# Restore previous velocity when dash ends.
	player.velocity = _old_velocity

func process(_delta: float) -> State:
	# Maintain constant dash velocity.
	player.velocity = _dash_direction * dash_speed
	_timer -= _delta
	if _timer <= 0:
		# After dash time, transition to idle (or another state).
		return get_node("../Idle")
	return null
