class_name State_Death extends State


@onready var animation_player : AnimationPlayer = $"../../AnimationPlayer"

@export var knockback_speed : float = 200.0
@export var decelerate_speed : float = 10.0
@export var invulnerable_duration : float = 0.6

var direction : Vector2
var hurt_box : HurtBox

var next_state : State = null

@onready var idle : State = $"../Idle"

func init() -> void:
	player.player_dead.connect( _player_dead )
	
## What happens when the player enters this State?
func enter() -> void:
	player.animation_player.animation_finished.connect( _animation_finished )
	
	direction = player.global_position.direction_to( hurt_box.global_position )
	player.velocity = direction * -knockback_speed
	player.set_direction()
	
	player.update_animation("death")
	player.make_invulnerable( invulnerable_duration )
	player.effect_animation_player.play("damaged")
	
	pass

func process( _delta : float ) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	return next_state

## What happens when the player exits this State?
func exit() -> void:
	next_state = null
	player.animation_player.animation_finished.disconnect( _animation_finished )
	player.effect_animation_player.play("resurrection")
	pass

func _player_dead( _hurt_box : HurtBox ) -> void:
	hurt_box = _hurt_box
	state_machine.change_state( self )
	pass

func _animation_finished( _a: String ) -> void:
	SaveManager.load_game()
	await LevelManager.level_load_started
	next_state = idle
