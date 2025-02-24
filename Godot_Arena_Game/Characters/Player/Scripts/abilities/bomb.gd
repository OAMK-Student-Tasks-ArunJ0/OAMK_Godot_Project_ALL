class_name Bomb extends Node2D

enum State { INACTIVE, THROW }

var player : Player
var direction : Vector2
var speed : float = 0
var state

@export var max_speed : float = 300
@export var max_distance_from_player : float = 300  # Maximum distance before the knife is deleted

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hurt_box: HurtBox = $HurtBox
@onready var bomb_hurt_box: HurtBox = $HurtBox
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	visible = false
	state = State.INACTIVE
	player = PlayerManager.player
	animation_player.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if state == State.THROW:
		position += direction * speed * delta

		# Check distance from player
		var distance_from_player = global_position.distance_to(player.global_position)
		if distance_from_player > max_distance_from_player or hurt_box.has_hit:
			speed = 0
			animation_player.play("explode")

func throw(throw_direction: Vector2) -> void:
	hurt_box.init_damage(1)
	bomb_hurt_box.init_damage(player.ranged_damage)
	hurt_box.has_hit = false  # Reset has_hit manually
	direction = throw_direction
	speed = max_speed
	state = State.THROW
	animation_player.play("bomb")
	visible = true

func _on_animation_finished(_a: String) -> void:
	animation_player.animation_finished.disconnect(_on_animation_finished)
	queue_free()
	pass
