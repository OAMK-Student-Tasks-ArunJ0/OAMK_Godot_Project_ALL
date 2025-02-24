class_name EnemyStateCharge extends EnemyState

@export var anim_name : String = "walk"
@export var charge_speed : float = 40.0
@export var turn_rate : float = 0.25
@export var stop_distance: float = 20.0  # Minimum distance to stop the enemy
@export var attack_cooldown: float = 2.0
@export var ranged_attack_cooldown: float = 3.0
@export var enemy_aggro_dur : float = 1.5

@export_category("AI")
@export var next_state : EnemyState
@export var attack_state : EnemyState  # Can be null for enemies that only chase
@export var ranged_attack_state : EnemyState  # Can be null for enemies that only chase
@export var vision_range : VisionRange
@export var enemy_attack_range : EnemyAttackRange
@export var enemy_ranged_attack_range : EnemyRangedAttackRange

# NEW: Attack cooldown (in seconds)

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var _timer : float = 0.0
var _direction : Vector2
var _enemy_sees_player : bool = false
var _player_in_attack_range: bool = false
var _player_in_ranged_attack_range: bool = false

# Tracks how long until we can attack again
var _attack_cooldown_timer: float = 0.0
var _ranged_attack_cooldown_timer: float = 0.0

# Initialization
func init() -> void:
	if vision_range:
		vision_range.player_entered.connect(_on_player_seen)
		vision_range.player_exited.connect(_on_player_not_seen)
	if enemy_attack_range:
		enemy_attack_range.player_entered.connect(_on_player_entered_attack_range)
		enemy_attack_range.player_exited.connect(_on_player_exited_attack_range)
	if enemy_ranged_attack_range:
		enemy_ranged_attack_range.player_entered_ranged.connect(_on_player_entered_ranged_attack_range)
		enemy_ranged_attack_range.player_exited_ranged.connect(_on_player_exited_ranged_attack_range)
		_ranged_attack_cooldown_timer = ranged_attack_cooldown
	pass

# Enter the state
func enter() -> void:
	_timer = enemy_aggro_dur
	_enemy_sees_player = true

	# Reinitialize direction
	var players_direction: Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	_direction = players_direction.normalized()
	enemy.set_direction(_direction)

	# Set velocity and animation
	enemy.velocity = _direction * charge_speed
	enemy.update_animation(anim_name)
	pass

# Exit the state
func exit() -> void:
	_enemy_sees_player = false
	pass

# Process the state
func process(_delta: float) -> EnemyState:
	# Decrement the attack cooldown timer each frame
	_attack_cooldown_timer -= _delta
	_ranged_attack_cooldown_timer -= _delta

	# Calculate the distance to the player
	var player_position = PlayerManager.player.global_position
	var distance_to_player = enemy.global_position.distance_to(player_position)

	# Update direction towards the player gradually
	var players_direction: Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	_direction = lerp(_direction, players_direction, turn_rate)  # Turn towards player gradually
	
	# Stop or move the enemy
	if distance_to_player <= stop_distance:
		enemy.velocity = Vector2.ZERO
	else:
		enemy.velocity = _direction * charge_speed
	
	# Update direction & animation if changed
	if enemy.set_direction(_direction):
		enemy.update_animation(anim_name)

	# Only attempt to attack if attack_state is not null
	if attack_state != null:
		# Attempt to attack if:
		#  1) player is in attack range,
		#  2) cooldown is finished (<= 0).
		if _player_in_attack_range and _attack_cooldown_timer <= 0:
			# Reset the cooldown timer
			_attack_cooldown_timer = attack_cooldown
			_ranged_attack_cooldown_timer = ranged_attack_cooldown
			return attack_state
		elif ranged_attack_state != null and _player_in_ranged_attack_range and _ranged_attack_cooldown_timer <= 0:
			# cooldown timer and ranged attack
			_ranged_attack_cooldown_timer = ranged_attack_cooldown
			return ranged_attack_state

	# If we no longer see the player, count down the aggro timer
	if not _enemy_sees_player:
		_timer -= _delta
		if _timer < 0:
			return next_state  # Transition if player not seen for a duration
	else:
		# Reset timer if we still see the player
		_timer = enemy_aggro_dur

	return null

# Player enters vision range
func _on_player_seen() -> void:
	print("Enemy Sees Player")
	_enemy_sees_player = true
	if (state_machine.current_state is EnemyStateStun 
	or state_machine.current_state is EnemyStateDestroy 
	or state_machine.current_state is EnemyStateAttack):
		return
	else:
		state_machine.change_state(self)
	pass

# Player exits vision range
func _on_player_not_seen() -> void:
	_enemy_sees_player = false
	pass

# Player enters attack range
func _on_player_entered_attack_range() -> void:
	_player_in_attack_range = true
	pass

# Player exits attack range
func _on_player_exited_attack_range() -> void:
	_player_in_attack_range = false
	pass

# Player enters attack range
func _on_player_entered_ranged_attack_range() -> void:
	_player_in_ranged_attack_range = true
	pass

# Player exits attack range
func _on_player_exited_ranged_attack_range() -> void:
	_player_in_ranged_attack_range = false
	pass
