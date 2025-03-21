# shuriken.gd
# Represents a shuriken projectile thrown by the player.
# It travels in a direction until its speed decelerates, then returns to the player.

class_name Shuriken extends Node2D

enum State { INACTIVE, THROW, RETURN }

var player: Player
var direction: Vector2
var speed: float = 0
var state

@export var acceleration: float = 500
@export var max_speed: float = 400

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var shuriken_hurt_box: HurtBox = $HurtBox

func _ready() -> void:
	visible = false
	state = State.INACTIVE
	player = PlayerManager.player

func _physics_process(delta: float) -> void:
	if state == State.THROW:
		# Decelerate the shuriken.
		speed -= acceleration * delta
		position += direction * speed * delta
		if speed <= 0:
			state = State.RETURN
	elif state == State.RETURN:
		# Return to the player.
		direction = global_position.direction_to(player.global_position)
		speed += acceleration * delta
		position += direction * speed * delta
		if global_position.distance_to(player.global_position) <= 10:
			queue_free()
	
	# Adjust audio pitch and animation speed based on current speed.
	var speed_ratio = speed / max_speed
	audio.pitch_scale = speed_ratio * 0.7 + 0.75
	animation_player.speed_scale = 1 + (speed_ratio * 0.25)
	pass

func throw(throw_direction: Vector2) -> void:
	# Initialize the shuriken's damage.
	shuriken_hurt_box.init_damage(player.ranged_damage)
	print("shuriken damage is " + str(shuriken_hurt_box.damage))
	direction = throw_direction
	speed = max_speed
	state = State.THROW
	animation_player.play("shuriken")
	visible = true
	pass
