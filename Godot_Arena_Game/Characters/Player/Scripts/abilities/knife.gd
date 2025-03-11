# knife.gd
# Represents a knife projectile that the player can throw.
# It travels until it reaches a maximum distance or hits something, then is removed.

class_name Knife extends Node2D

enum State { INACTIVE, THROW }

var player: Player
var direction: Vector2
var speed: float = 0
var state

@export var max_speed: float = 300
@export var max_distance_from_player: float = 300  # Maximum allowed distance from the player.

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
		# Check if the knife is too far or if it has hit an object.
		var distance_from_player = global_position.distance_to(player.global_position)
		if distance_from_player > max_distance_from_player or knife_hurt_box.has_hit:
			queue_free()

func throw(throw_direction: Vector2) -> void:
	# Initialize damage and reset hit flag.
	knife_hurt_box.init_damage(player.ranged_damage)
	knife_hurt_box.has_hit = false
	direction = throw_direction
	speed = max_speed
	state = State.THROW
	animation_player.play("knife_" + anim_direction(throw_direction))
	visible = true

func anim_direction(cardinal_direction: Vector2) -> String:
	# Determine the proper animation direction string based on the throw direction.
	if cardinal_direction == Vector2.DOWN:
		return "south"
	elif cardinal_direction == Vector2.UP:
		return "north"
	elif cardinal_direction == Vector2.LEFT:
		return "west"
	elif cardinal_direction == Vector2.RIGHT:
		return "east"
	# Diagonals
	elif cardinal_direction.x > 0 and cardinal_direction.y < 0:
		return "north_east"
	elif cardinal_direction.x > 0 and cardinal_direction.y > 0:
		return "south_east"
	elif cardinal_direction.x < 0 and cardinal_direction.y > 0:
		return "south_west"
	elif cardinal_direction.x < 0 and cardinal_direction.y < 0:
		return "north_west"
	else:
		print("Unknown direction: ", cardinal_direction)
		return "north"  # Default fallback.
