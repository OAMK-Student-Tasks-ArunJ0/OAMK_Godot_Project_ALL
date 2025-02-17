class_name Knife extends Node2D

enum State { INACTIVE, THROW }

var player : Player
var direction : Vector2
var speed : float = 0
var state

@export var max_speed : float = 300
@export var max_distance_from_player : float = 300  # Maximum distance before the knife is deleted

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var knife_hurt_box: HurtBox = $HurtBox
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	visible = false
	state = State.INACTIVE
	player = PlayerManager.player

func _physics_process(delta: float) -> void:
	if state == State.THROW:
		position += direction * speed * delta

		# Check distance from player
		var distance_from_player = global_position.distance_to(player.global_position)
		if distance_from_player > max_distance_from_player or knife_hurt_box.has_hit:
			queue_free()  # Delete the knife if it's too far or has hit something

func throw(throw_direction: Vector2) -> void:
	knife_hurt_box.init_damage(player.ranged_damage)
	knife_hurt_box.has_hit = false  # Reset has_hit manually
	direction = throw_direction
	speed = max_speed
	state = State.THROW
	animation_player.play("knife_" + anim_direction(throw_direction) )
	visible = true

func anim_direction(cardinal_direction: Vector2) -> String:
	if cardinal_direction == Vector2.DOWN:
		return "south"
	elif cardinal_direction == Vector2.UP:
		return "north"
	elif cardinal_direction == Vector2.LEFT:
		return "west"
	elif cardinal_direction == Vector2.RIGHT:
		return "east"
	# Diagonal directions
	elif cardinal_direction.x > 0 and cardinal_direction.y < 0:  # North-east
		return "north_east"
	elif cardinal_direction.x > 0 and cardinal_direction.y > 0:  # South-east
		return "south_east"
	elif cardinal_direction.x < 0 and cardinal_direction.y > 0:  # South-west
		return "south_west"
	elif cardinal_direction.x < 0 and cardinal_direction.y < 0:  # North-west
		return "north_west"
	else:
		print("Unknown direction: ", cardinal_direction)
		return "north"  # Default fallback
