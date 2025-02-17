class_name State_Dash
extends State

@export var dash_speed : float = 250.0
@export var dash_duration : float = 0.24
@export var dash_anim_name : String = "dash"

var _timer : float = 0.0
var _old_velocity : Vector2
var _dash_direction : Vector2

func init() -> void:
	# One-time initialization if needed
	pass

func enter() -> void:
	# 1) Save the old velocity to restore later
	_old_velocity = player.velocity

	# 2) Get the player's cardinal_direction
	_dash_direction = player.cardinal_direction

	# 3) Force velocity
	player.velocity = _dash_direction * dash_speed

	# 4) Start dash timer
	_timer = dash_duration

	# 5) Update to the dash animation 
	#    (The player’s update_animation("dash") method will automatically append
	#     _down, _up, _left, or _right based on the player's cardinal_direction.)
	player.update_animation(dash_anim_name)

	# (Optional) If you want invincibility
	player.make_invulnerable(dash_duration)

func exit() -> void:
	# End dash, restore old velocity
	player.velocity = _old_velocity
	# Optionally revert to idle or let the next state set the animation

func process(_delta: float) -> State:
	# Keep reapplying dash velocity, so it remains locked to that direction
	player.velocity = _dash_direction * dash_speed

	# Count down
	_timer -= _delta
	if _timer <= 0:
		# After dash time ends, transition to Idle (or Walk)
		return get_node("../Idle")  # or "../Walk", etc.

	return null
