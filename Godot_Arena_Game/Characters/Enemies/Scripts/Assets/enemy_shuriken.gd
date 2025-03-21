# enemy_shuriken.gd
# This node represents a shuriken thrown by an enemy.
# It travels in a straight line with deceleration and is removed if it travels too far.

class_name EnemyShuriken extends Node2D

var direction: Vector2
var speed: float = 0

@export var max_speed: float = 200.0
@export var max_distance: float = 750  # Maximum travel distance before deletion.
@export var shuriken_damage: int = 4
@export var stop_at_hitboxes : bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var shuriken_hurt_box: HurtBox = $HurtBox

# Spawn position is recorded to check travel distance.
var spawn_position: Vector2


func _ready() -> void:
	visible = false

func _physics_process(delta: float) -> void:
	# Move the shuriken.
	position += direction * speed * delta
	
	# Delete the shuriken if it exceeds its maximum distance.
	var distance_from_spawn = global_position.distance_to(spawn_position)
	if distance_from_spawn > max_distance or (shuriken_hurt_box.has_hit ==true && stop_at_hitboxes == true):
		speed = 0
		queue_free()
	
	# Update audio pitch and animation speed based on current speed.
	var speed_ratio = speed / max_speed
	audio.pitch_scale = speed_ratio * 0.7 + 0.75
	animation_player.speed_scale = 1 + (speed_ratio * 0.25)

func throw(throw_direction: Vector2) -> void:
	# Initialize the hurt box damage.
	shuriken_hurt_box.init_damage(shuriken_damage)
	direction = throw_direction
	speed = max_speed
	animation_player.play("shuriken")
	visible = true
	# Set spawn position now that the shuriken is thrown.
	spawn_position = global_position
