class_name EnemyShuriken extends Node2D

var direction: Vector2
var speed: float = 0

@export var max_speed: float = 300
@export var max_distance: float = 1000  # Maximum distance before deletion
@export var catch_audio: AudioStream
@export var shuriken_damage : int = 2

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var shuriken_hurt_box: HurtBox = $HurtBox

func _ready() -> void:
	visible = false

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	# Delete if too far from spawn point
	if global_position.distance_to(global_position - position) > max_distance:
		queue_free()
	
	# Update audio and animation speed based on speed
	var speed_ratio = speed / max_speed
	audio.pitch_scale = speed_ratio * 0.7 + 0.75
	animation_player.speed_scale = 1 + (speed_ratio * 0.25)

func throw(throw_direction: Vector2) -> void:
	shuriken_hurt_box.init_damage(shuriken_damage)  # Set default damage or pass it as parameter
	direction = throw_direction
	speed = max_speed
	animation_player.play("shuriken")
	PlayerManager.play_audio(catch_audio)
	visible = true
