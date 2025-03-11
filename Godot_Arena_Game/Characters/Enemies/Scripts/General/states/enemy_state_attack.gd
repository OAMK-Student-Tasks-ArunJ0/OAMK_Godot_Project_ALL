# enemy_state_attack.gd
# This state handles a melee attack from the enemy.
# It plays the attack animation, enables the enemy's attack hurt box briefly,
# and then transitions to the next state.

class_name EnemyStateAttack extends EnemyState

@export var anim_name: String = "charge"  # Animation used during attack.
@export var attack_anim_dur: float = 0.6  # Duration of the attack animation.

@export_category("AI")
@export var next_state: EnemyState  # State to transition to after attack.

@export_category("Sounds")
@export var sword_sounds: Array[AudioStream]  # Array of attack sound effects.
@onready var audio: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var enemy_attack_area: HurtBox = $"../../Sprite2D/EnemyAttackHurtBox"  # Hurt box for enemy attack.

var _animation_finished: bool = false
var _attack_timer: float = 0.0

func enter() -> void:
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	
	# Play a random attack sound with slight pitch variation.
	audio.stream = sword_sounds[randi() % sword_sounds.size()]
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	
	# Reorient the enemy toward the player.
	var players_direction: Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	var _direction = players_direction.normalized()
	enemy.set_direction(_direction)
	
	# Enable the enemy's attack hurt box.
	if enemy_attack_area:
		enemy_attack_area.monitoring = true
	
	# Set the attack timer.
	_attack_timer = attack_anim_dur

func exit() -> void:
	if enemy_attack_area:
		enemy_attack_area.monitoring = false
	enemy.animation_player.animation_finished.disconnect(_on_animation_finished)
	_animation_finished = false
	enemy.velocity = Vector2.ZERO

func process(_delta: float) -> EnemyState:
	if _animation_finished:
		return next_state
	
	_attack_timer -= _delta
	if _attack_timer <= 0:
		return next_state
	
	return null

func _on_animation_finished(_a: String) -> void:
	_animation_finished = true
