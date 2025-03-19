# enemy_state_charge.gd
# This state makes the enemy charge toward the player.
# It uses a Navigator node to adjust movement direction, manages turning, and
# transitions to an attack state if conditions are met, or reverts if the player is lost.

class_name EnemyStateCharge extends EnemyState

const NAVIGATOR: PackedScene = preload("res://Characters/Enemies/Scenes/Function Scenes/navigator.tscn")

@export var anim_name: String = "walk"
@export var anim_name_idle: String = "idle"
@export var charge_speed: float = 40.0
@export var turn_rate: float = 0.25
@export var stop_distance: float = 20.0  # Distance at which the enemy stops charging
@export var attack_cooldown: float = 2.0
@export var ranged_attack_cooldown: float = 3.0
@export var enemy_aggro_dur: float = 5
@export var idle_CD_reducer: float = 1.1

@export_category("AI")
@export var next_state: EnemyState
@export var attack_state: EnemyState  # For melee attack (optional)
@export var ranged_attack_state: EnemyState  # For ranged attack (optional)
@export var vision_range: VisionRange
@export var enemy_attack_range: EnemyAttackRange
@export var enemy_ranged_attack_range: EnemyRangedAttackRange

# Attack cooldown timers.
var _attack_cooldown_timer: float = 0.0
var _ranged_attack_cooldown_timer: float = 0.0

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var navigator: Navigator
var _timer: float = 0.0
var _direction: Vector2
var _enemy_sees_player: bool = false
var _player_in_attack_range: bool = false
var _player_in_ranged_attack_range: bool = false

func init() -> void:
	# Connect signals from vision and attack range nodes.
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

func enter() -> void:
	# Instantiate a Navigator to assist with movement.
	navigator = NAVIGATOR.instantiate() as Navigator
	enemy.add_child(navigator)
	
	_timer = enemy_aggro_dur
	_enemy_sees_player = true

	# Initialize direction toward the player.
	var players_direction: Vector2 = enemy.global_position.direction_to(PlayerManager.player.global_position)
	_direction = players_direction.normalized()
	enemy.set_direction(_direction)

	# Set movement velocity and play charge animation.
	enemy.velocity = _direction * charge_speed
	enemy.update_animation(anim_name)
	pass

func exit() -> void:
	# Remove the navigator node and reset detection.
	navigator.queue_free()
	_enemy_sees_player = false
	pass

func process(_delta: float) -> EnemyState:
	# Update cooldown timers.
	_attack_cooldown_timer -= _delta * idle_CD_reducer
	_ranged_attack_cooldown_timer -= _delta * idle_CD_reducer

	# Calculate the distance to the player.
	var player_position = PlayerManager.player.global_position
	var distance_to_player = enemy.global_position.distance_to(player_position)
	
	# Adjust navigator raycast length based on proximity.
	if distance_to_player <= 30 and navigator.current_raycast_length != -15:
		navigator.set_raycast_length(-15)
	elif distance_to_player > 30 and navigator.current_raycast_length != -35:
		navigator.set_raycast_length(-35)
	
	# Adjust movement direction gradually toward the best path.
	_direction = lerp(_direction, navigator.move_direction, turn_rate)
	
	# If close enough to the player, stop and play idle animation.
	if distance_to_player <= stop_distance:
		enemy.velocity = Vector2.ZERO
		enemy.update_animation(anim_name_idle)
		idle_CD_reducer = 1.5
	else:
		enemy.velocity = _direction * charge_speed
		enemy.update_animation(anim_name)
		idle_CD_reducer = 1.0
	
	# Update enemy facing direction if necessary.
	if enemy.set_direction(_direction):
		if enemy.velocity == Vector2.ZERO:
			enemy.update_animation(anim_name_idle)
		else:
			enemy.update_animation(anim_name)

	# Transition to melee attack if within range and cooldown finished.
	if attack_state != null:
		if _player_in_attack_range and _attack_cooldown_timer <= 0:
			_attack_cooldown_timer = attack_cooldown
			_ranged_attack_cooldown_timer = ranged_attack_cooldown
			return attack_state
	# Transition to ranged attack if within ranged range and cooldown finished.
	if ranged_attack_state != null:
		if _player_in_ranged_attack_range and _ranged_attack_cooldown_timer <= 0:
			_ranged_attack_cooldown_timer = ranged_attack_cooldown
			return ranged_attack_state

	# If the enemy no longer sees the player, start a countdown.
	if not _enemy_sees_player:
		_timer -= _delta
		if _timer < 0:
			return next_state  # Transition out if aggro timer expires
	else:
		_timer = enemy_aggro_dur

	return null

func _on_player_seen() -> void:
	#print("Enemy Sees Player")
	_enemy_sees_player = true
	# If already in a hurt or attack state, do nothing.
	if (state_machine.current_state is EnemyStateHurt or 
		state_machine.current_state is EnemyStateDeath or 
		state_machine.current_state is EnemyStateAttack):
		return
	else:
		state_machine.change_state(self)
	pass

func _on_player_not_seen() -> void:
	_enemy_sees_player = false
	pass

func _on_player_entered_attack_range() -> void:
	_player_in_attack_range = true
	pass

func _on_player_exited_attack_range() -> void:
	_player_in_attack_range = false
	pass

func _on_player_entered_ranged_attack_range() -> void:
	_player_in_ranged_attack_range = true
	pass

func _on_player_exited_ranged_attack_range() -> void:
	_player_in_ranged_attack_range = false
	pass
