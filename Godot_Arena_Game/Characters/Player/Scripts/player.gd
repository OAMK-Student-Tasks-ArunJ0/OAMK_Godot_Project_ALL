# player.gd
# This script defines the main Player character.
# It handles movement, animations, health/damage, and attack direction updates.

class_name Player extends CharacterBody2D

# Signals emitted when the player changes direction, takes damage, or dies.
signal direction_changed(new_direction: Vector2)
signal player_damaged(hurt_box: HurtBox)
signal player_dead(hurt_box: HurtBox)

# Four cardinal directions (right, down, left, up).
const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

# Current facing direction used for animations and attacks.
var cardinal_direction: Vector2 = Vector2.DOWN
# Raw input direction.
var direction: Vector2 = Vector2.ZERO

# Health and damage properties.
var invulnerable: bool = false
var hp: int = 12
var max_hp: int = 12
var health_timer: float = 0.0
var sword_damage: int = 1 
var sword_range: float = 1.0
var ranged_damage: int = 1

# Ranged weapon name and dash ability flag.
var ranged_weapon: String = ""
var dash_unlocked: bool = false

@export var health_regen_time: float = 5.0
var health_regen : bool = true
var abilities_allowed : bool = true

# Node references.
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var hit_box: HitBox = $HitBox
@onready var sprite: Sprite2D = $Sprite2D
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var audio: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var attack_hurt_box: HurtBox = %AttackHurtBox
@onready var abilities: Abilities = $Abilities

func _ready() -> void:
	# Register this player instance with the PlayerManager.
	PlayerManager.player = self
	# Initialize the state machine with a reference to this player.
	state_machine.Initialize(self)
	# Connect the hit box signal to handle damage.
	hit_box.damaged.connect(_take_damage)
	# Set initial health display (example value update).
	update_hp(100)
	# Initialize the damage of the player's attack hitbox.
	attack_hurt_box.init_damage(sword_damage)
	pass

func _process(_delta: float) -> void:
	# Decrement health regeneration timer.
	health_timer -= _delta
	if health_timer < 0 and health_regen == true:
		# Regenerate health if low or at 0.
		if hp <= max_hp / 4 or hp == 0:
			update_hp(+1)
		health_timer = health_regen_time
	
	# If the player is dashing, skip normal movement input.
	if state_machine.current_state is State_Dash:
		return
	
	# Read normalized movement input.
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	pass

func _physics_process(_delta: float) -> void:
	# Use built-in move_and_slide for movement.
	move_and_slide()

func set_direction() -> bool:
	# If no input, do nothing.
	if direction == Vector2.ZERO:
		return false
	
	# Calculate an index from the current input direction, adjusted by current facing.
	var direction_id: int = int(round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()))
	var new_dir = DIR_4[direction_id]  # New cardinal direction (0-3).
	
	if new_dir == cardinal_direction:
		return false
	
	# Update the facing direction and emit a signal.
	cardinal_direction = new_dir
	direction_changed.emit(new_dir)
	return true

func update_animation(state: String) -> void:
	# Play an animation for the given state appended with the current direction.
	animation_player.play(state + "_" + anim_direction())
	pass

func anim_direction() -> String:
	# Return a string representation of the current facing direction.
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	elif cardinal_direction == Vector2.RIGHT:
		return "right"
	else:
		return "down"  # Fallback.

func _take_damage(hurt_box: HurtBox) -> void:
	# Ignore damage if invulnerable.
	if invulnerable:
		return
	# Decrease HP based on the damage value.
	update_hp(-hurt_box.damage)
	if hp > 1:
		player_damaged.emit(hurt_box)
	else:
		health_regen = false
		# Emit death signal when HP falls to 0.
		player_dead.emit(hurt_box)
	pass

func update_hp(delta: int) -> void:
	# Adjust HP and update the HUD display.
	hp = clampi(hp + delta, 0, max_hp)
	PlayerHud.update_hp(hp, max_hp)
	pass

func update_max_hp(delta: int) -> void:
	# Increase maximum HP and update the HUD.
	max_hp += delta
	PlayerHud.update_hp(hp, max_hp)
	pass

func update_weapons(melee_range_upgrade: float, melee_upgrade: int, ranged_upgrade: int) -> void:
	# Upgrade weapon stats.
	sword_range += melee_range_upgrade
	sword_damage += melee_upgrade
	ranged_damage += ranged_upgrade
	# Reinitialize the damage of the attack hitbox.
	attack_hurt_box.init_damage(sword_damage)
	pass
	
func make_invulnerable(_duration: float = 1.0) -> void:
	# Enable temporary invulnerability.
	invulnerable = true
	hit_box.monitoring = false
	
	# Wait for the duration before restoring vulnerability.
	await get_tree().create_timer(_duration).timeout
	
	invulnerable = false
	hit_box.monitoring = true
	pass
