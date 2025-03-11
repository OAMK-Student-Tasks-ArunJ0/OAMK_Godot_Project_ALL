# state_stun.gd
# Handles the stunned state when the player is knocked back and temporarily unable to act.
# The state listens for damage events and transitions back to idle afterward.

class_name State_Stun extends State

@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0
@export var invulnerable_duration: float = 0.6

var hurt_box: HurtBox
var direction: Vector2

var next_state: State = null

@onready var idle: State = $"../Idle"

func init() -> void:
	# Connect the player's damage signal to trigger the stun.
	player.player_damaged.connect(_player_damaged)

func enter() -> void:
	player.abilities_allowed = false
	# Connect to the animation finished signal.
	player.animation_player.animation_finished.connect(_animation_finished)
	# Calculate knockback direction based on the hurt_box position.
	direction = player.global_position.direction_to(hurt_box.global_position)
	player.velocity = direction * -knockback_speed
	player.set_direction()
	# Play the hurt animation and apply invulnerability.
	player.update_animation("hurt")
	player.make_invulnerable(invulnerable_duration)
	player.effect_animation_player.play("damaged")
	pass

func exit() -> void:
	next_state = null
	player.animation_player.animation_finished.disconnect(_animation_finished)
	player.abilities_allowed = true
	pass

func process(_delta: float) -> State:
	# Gradually reduce velocity.
	player.velocity -= player.velocity * decelerate_speed * _delta
	return next_state

func physics(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	return null

func _player_damaged(_hurt_box: HurtBox) -> void:
	# Update the hurt_box and change state to stun.
	hurt_box = _hurt_box
	state_machine.change_state(self)
	pass

func _animation_finished(_a: String) -> void:
	# Once the hurt animation finishes, transition back to idle.
	next_state = idle
