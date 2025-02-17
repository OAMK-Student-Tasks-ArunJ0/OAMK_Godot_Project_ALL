class_name Shuriken extends Node2D

enum State { INACTIVE, THROW, RETURN }

var player : Player
var direction : Vector2
var speed : float = 0
var state

@export var acceleration : float = 500
@export var max_speed : float = 400
@export var catch_audio : AudioStream

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var shuriken_hurt_box: HurtBox = $HurtBox

func _ready() -> void:
	visible = false
	state = State.INACTIVE
	player = PlayerManager.player


func _physics_process(delta: float) -> void:
	# delta is the time, we use it because i dont want it to rely on frames
	if state == State.THROW:
		speed -= acceleration * delta
		position += direction * speed * delta
		if speed <= 0:
			state = State.RETURN
		pass
	elif state == State.RETURN:
		direction = global_position.direction_to( player.global_position )
		speed += acceleration * delta
		position += direction * speed * delta
		if global_position.distance_to( player.global_position ) <= 10:
			PlayerManager.play_audio( catch_audio )
			queue_free()
		pass
	
	var speed_ratio = speed / max_speed
	audio.pitch_scale = speed_ratio * 0.7 + 0.75
	animation_player.speed_scale = 1 + ( speed_ratio * 0.25 )
	pass


func throw( throw_direction : Vector2 ) -> void:
	shuriken_hurt_box.init_damage( player.ranged_damage )
	print("shuriken damage is "+str(shuriken_hurt_box.damage))
	direction = throw_direction
	speed = max_speed
	state = State.THROW
	animation_player.play("shuriken")
	PlayerManager.play_audio( catch_audio )
	visible = true
	pass
