# enemy_bomb.gd
# This node represents a bomb projectile thrown by an enemy.
# It travels in a set direction until it reaches a maximum distance or collides,
# then plays an explosion animation and frees itself.

class_name EnemyBomb extends Node2D
enum State { INACTIVE, THROW }
var direction: Vector2
var speed: float = 0
var state
var spawn_position: Vector2  # For tracking distance traveled
var parent_enemy: Node2D  # Reference to the enemy that threw the bomb

@export var max_speed: float = 250
@export var max_distance: float = 500  # Maximum travel distance before explosion
@export var bomb_damage: int = 3  # Damage inflicted by the bomb explosion
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: HurtBox = $HurtBox
@onready var bomb_hurt_box: HurtBox = $BombHurtBox
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	visible = false
	state = State.INACTIVE
	animation_player.animation_finished.connect(_on_animation_finished)
	# Hurt boxes remain disabled until the bomb is thrown.
	pass

func _physics_process(delta: float) -> void:
	if state == State.THROW:
		position += direction * speed * delta
		
		# Update audio pitch based on speed.
		var speed_ratio = speed / max_speed
		audio.pitch_scale = speed_ratio * 0.7 + 0.75
		
		# Check if the bomb has traveled too far or collided.
		var distance_from_spawn = global_position.distance_to(spawn_position)
		if distance_from_spawn > max_distance or hurt_box.has_hit:
			speed = 0
			animation_player.play("explode")
			state = State.INACTIVE  # Prevent further movement
	pass

func throw(throw_direction: Vector2, thrower: Node2D = null) -> void:
	# Initialize damage values.
	hurt_box.init_damage(1)
	bomb_hurt_box.init_damage(bomb_damage)
	hurt_box.has_hit = false
	# Store a reference to the enemy that threw the bomb.
	parent_enemy = thrower
	direction = throw_direction.normalized()
	speed = max_speed
	state = State.THROW
	animation_player.play("bomb")
	visible = true
	# Record the spawn position for distance calculations.
	spawn_position = global_position
	pass

func _on_animation_finished(anim_name: String) -> void:
	# Once the explosion animation is finished, free the bomb node.
	if anim_name == "explode":
		animation_player.animation_finished.disconnect(_on_animation_finished)
		queue_free()
	pass
