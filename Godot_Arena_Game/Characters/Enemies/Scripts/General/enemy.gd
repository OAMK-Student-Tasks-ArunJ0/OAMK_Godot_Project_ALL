# enemy.gd
# This script defines a basic enemy character.
# It handles health, damage reception, animations, directional updates,
# and communication with the enemy state machine and health bar.

class_name Enemy extends CharacterBody2D

# If true, use full directional animations; if false, use only side sprites.
@export var side_or_both_animations = true

# Signals for direction changes, when damaged, and when dead.
signal direction_changed(new_direction: Vector2)
signal enemy_damaged(hurt_box: HurtBox)
signal enemy_dead(hurt_box: HurtBox)

# Define the four cardinal directions.
const DIR_4 = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

# Health properties.
@export var hp: int = 3
@export var max_hp: int = 3  # Used for scaling the health bar

# Current facing direction (cardinal) and raw movement direction.
var cardinal_direction: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO

# Reference to the player (set in _ready).
var player: Player

# Invulnerability flag used to provide temporary damage immunity (e.g. during stun).
var invulnerable: bool = false

# Node references.
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_box: HitBox = $HitBox
@onready var state_machine: EnemyStateMachine = $EnemyStateMachine
@onready var health_bar: EnemyHealthBar = $EnemyHealthBar  # Health bar UI for the enemy

func _ready() -> void:
	# Initialize the enemy state machine with a reference to this enemy.
	state_machine.initialize(self)
	# Get the player instance from the PlayerManager.
	player = PlayerManager.player  # Ensure player is before enemies in the scene tree
	# Connect the hit box signal to take damage.
	hit_box.damaged.connect(_take_damage)
	# Initialize and update the health bar.
	health_bar.initialize()
	update_health_bar()
	pass

func _process(_delta: float) -> void:
	# Additional per-frame logic can be added here.
	pass

func _physics_process(_delta):
	# Move the enemy using built-in physics.
	move_and_slide()

func set_direction(_new_direction: Vector2) -> bool:
	# Set the enemy's movement direction and update its facing.
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false

	# Calculate an index from the current input direction, adjusted by the current cardinal direction.
	var direction_id: int = int(round((direction + cardinal_direction * 0.1).angle() / TAU * DIR_4.size()))
	var new_dir = DIR_4[direction_id]  # New cardinal direction (0-3)

	# If no change, do nothing.
	if new_dir == cardinal_direction:
		return false

	# Update the facing direction and emit the signal.
	cardinal_direction = new_dir
	direction_changed.emit(new_dir)

	# If using side-only animations, flip the sprite horizontally when facing left.
	if side_or_both_animations == false:
		sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1

	return true

func update_animation(state: String) -> void:
	# Build the animation name based on the state and current direction.
	var anim_name = state + "_" + anim_direction()
	# Check if the animation exists and play it; otherwise, warn.
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	else:
		print("Warning: Animation not found: ", anim_name)

func anim_direction() -> String:
	# Return a string representing the direction to be appended to animation names.
	if side_or_both_animations == false:
		# Only use up, down, or side animations.
		if cardinal_direction == Vector2.DOWN:
			return "down"
		elif cardinal_direction == Vector2.UP:
			return "up"
		else:
			return "side"
	else:
		# Use full directional animations.
		if cardinal_direction == Vector2.DOWN:
			return "down"
		elif cardinal_direction == Vector2.UP:
			return "up"
		elif cardinal_direction == Vector2.LEFT:
			return "left"
		elif cardinal_direction == Vector2.RIGHT:
			return "right"
	return "down"  # Fallback

func _take_damage(hurt_box: HurtBox) -> void:
	# Ignore damage if invulnerable.
	if invulnerable:
		return
	# Subtract damage from HP and clamp to a minimum of 0.
	hp -= hurt_box.damage
	hp = max(hp, 0)
	# Update the health bar display.
	update_health_bar()

	# Emit appropriate signals based on remaining HP.
	if hp > 0:
		enemy_damaged.emit(hurt_box)
		
		### DEBUG ENEMY TAKE DAMAGE
		#print("DEBUG: ", name," otti ", hurt_box.damage, " vahinkoa!")
	else:
		enemy_dead.emit(hurt_box)
		
		### DEBUG PLAYER DEAD
		#print("DEBUG: ", name," kuoli!")

func update_health_bar() -> void:
	# Delegate updating the health bar to the EnemyHealthBar node.
	health_bar.update_health(hp, max_hp)
