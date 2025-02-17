class_name EnemyStateIdleWalk extends EnemyState

@export var anim_name : String = "walk"
@export var wander_speed : float = 20.0

@export_category("AI")
@export var state_animation_duration : float = 0.5
@export var state_cycles_min : int = 1 # amount of times the animation happens
@export var state_cycles_max : int = 3
@export var next_state : EnemyState


var _timer : float = 0.0
var _direction : Vector2


# What happens when we initialize this state?
func init() -> void:
	pass


# what happens when enemy enters this state
func enter() -> void:
	_timer = randi_range( state_cycles_min, state_cycles_max ) * state_animation_duration
	var rand = randi_range( 0, 3 )
	_direction = enemy.DIR_4[ rand ]
	enemy.velocity = _direction * wander_speed
	enemy.set_direction( _direction )
	enemy.update_animation( anim_name )
	pass


# what happens when enemy exits state
func exit() -> void:
	pass


## What happens when during the _process update in this state 
func process( _delta: float ) -> EnemyState:
	_timer -= _delta
	if _timer < 0:
		return next_state
	return null


## What happens during the _physics_process update in this state
func physics( _delta: float ) -> EnemyState:
	return null
