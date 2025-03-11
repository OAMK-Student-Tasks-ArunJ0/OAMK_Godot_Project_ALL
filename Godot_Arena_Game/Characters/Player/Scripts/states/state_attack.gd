# state_attack.gd
# Handles the player's attack state.
# Plays the attack animation, activates the hurtbox briefly, and then transitions back to idle or walk.

class_name State_Attack extends State

var attacking: bool = false

@export_range(1, 20, 0.5) var decelerate_speed: float = 5.0

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

@onready var idle: State = $"../Idle"
@onready var walk: State = $"../Walk"
@onready var hurt_box: HurtBox = %AttackHurtBox

@export_category("Sounds")
@export var sword_sounds: Array[AudioStream]  # Array of sword swing sounds.
@onready var swing_sprite: Sprite2D = $"../../Sprite2D/SwingSprite2D"
@onready var swing_hurt_box: HurtBox = %AttackHurtBox

var attack_timer: float = 0.5

func enter() -> void:
	# Scale the swing sprite and hurtbox based on the player's sword range.
	var scale_factor = Vector2(1.0 * player.sword_range, 1.0 * player.sword_range)
	swing_sprite.scale = scale_factor
	swing_hurt_box.scale = scale_factor
	
	# Play the attack animation.
	player.update_animation("attack")
	animation_player.animation_finished.connect(_end_attack)
	
	# Play a random sword sound with slight pitch variation.
	audio.stream = sword_sounds[randi() % sword_sounds.size()]
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	
	attacking = true
	
	# After a short delay, enable the attack hurtbox.
	await get_tree().create_timer(0.075).timeout
	if attacking:
		hurt_box.monitoring = true
	pass

func exit() -> void:
	animation_player.animation_finished.disconnect(_end_attack)
	attacking = false
	hurt_box.monitoring = false
	pass

func process(_delta: float) -> State:
	# Decelerate the player's velocity during the attack.
	player.velocity -= player.velocity * decelerate_speed * _delta
	
	# After the attack, return to idle or walk based on input.
	if not attacking:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null

func physics(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	return null

func _end_attack(_newAnimName: String) -> void:
	# Mark the attack as finished.
	attacking = false
