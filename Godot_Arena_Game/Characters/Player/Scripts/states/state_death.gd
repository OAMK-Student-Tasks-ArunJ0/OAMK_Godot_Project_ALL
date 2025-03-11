# state_death.gd
# Handles the player's death state.
# Plays the death animation, then shows the death screen and eventually transitions back to idle.

class_name State_Death extends State

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0
@export var invulnerable_duration: float = 0.6

var direction: Vector2
var hurt_box: HurtBox

var next_state: State = null

@onready var idle: State = $"../Idle"

func init() -> void:
	# Connect the player's death signal to trigger this state.
	player.player_dead.connect(_player_dead)

func enter() -> void:
	player.abilities_allowed = false
	# Connect to animation finish signal.
	player.animation_player.animation_finished.connect(_animation_finished)
	# Calculate knockback direction.
	direction = player.global_position.direction_to(hurt_box.global_position)
	player.velocity = direction * -knockback_speed
	player.set_direction()
	# Play the death animation and apply invulnerability.
	player.update_animation("death")
	player.make_invulnerable(invulnerable_duration)
	player.effect_animation_player.play("damaged")
	pass

func process(_delta: float) -> State:
	# Decelerate the player's velocity.
	player.velocity -= player.velocity * decelerate_speed * _delta
	return next_state

func exit() -> void:
	next_state = null
	player.animation_player.animation_finished.disconnect(_animation_finished)
	# Play a resurrection effect.
	player.effect_animation_player.play("resurrection")
	player.health_regen = true
	player.abilities_allowed = true
	pass

func _player_dead(_hurt_box: HurtBox) -> void:
	# Set the hurt_box and change state to death.
	hurt_box = _hurt_box
	state_machine.change_state(self)
	pass

func _animation_finished(_a: String) -> void:
	# When the death animation finishes, show the death screen.
	PlayerHud.death_screen.show_death_screen()
	PlayerHud.death_screen.load_last_save.grab_focus()
	next_state = idle
