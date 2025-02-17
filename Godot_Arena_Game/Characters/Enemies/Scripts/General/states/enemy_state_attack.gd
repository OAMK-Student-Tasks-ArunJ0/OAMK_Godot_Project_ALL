class_name EnemyStateAttack extends EnemyState

@export var anim_name : String = "charge"  # Attack animation name
@export var attack_anim_dur : float = 0.6  # Duration of the attack animation

@export_category("AI")
@export var next_state : EnemyState  # The next state to transition to after the attack

@export_category("Sounds")
@export var sword_sounds: Array[AudioStream]  # Sword sounds array
@onready var audio: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var enemy_attack_area : HurtBox = $"../../Sprite2D/EnemyAttackHurtBox"  # The hurt box for enemy's attack area

var _animation_finished : bool = false
var _attack_timer : float = 0.0  # Timer for attack duration

# Enter the state
func enter() -> void:
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	
	# Randomize the attack sound and play it
	audio.stream = sword_sounds[randi() % sword_sounds.size()]
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()

	# Reinitialize direction towards the player
	var players_direction: Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	var _direction = players_direction.normalized()
	enemy.set_direction(_direction)

	# Enable the attack hurt box (so the enemy can hurt the player)
	if enemy_attack_area:
		enemy_attack_area.monitoring = true

	# Set the velocity and play attack animation
	_attack_timer = attack_anim_dur  # Set the attack timer

# Exit the state
func exit() -> void:
	if enemy_attack_area:
		enemy_attack_area.monitoring = false  # Disable the hurt box after attack
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	_animation_finished = false
	
	# Reset any other states
	enemy.velocity = Vector2.ZERO

# Process the state (this runs every frame)
func process(_delta: float) -> EnemyState:
	# If the animation is finished, transition to the next state
	if _animation_finished:
		return next_state
	
	# Decrease the attack timer
	_attack_timer -= _delta
	if _attack_timer <= 0:
		return next_state  # Transition to the next state if time is up

	return null  # Keep the current state until the animation is done

# Handle animation finished callback
func _on_animation_finished(_a: String) -> void:
	_animation_finished = true  # Mark animation as finished

# Physics processing (if needed)
func physics(_delta: float) -> EnemyState:
	return null
