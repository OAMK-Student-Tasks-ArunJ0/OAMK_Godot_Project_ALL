class_name Enemy extends CharacterBody2D

@export var side_or_both_animations = true # if the enemy has side sprite or right/left sprites

signal direction_changed( new_direction : Vector2 )
signal enemy_damaged( hurt_box : HurtBox )
signal enemy_destroyed( hurt_box : HurtBox )

const DIR_4 = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]

@export var hp : int = 3

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var player : Player
var invulnerable : bool = false # for stun invincibility

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_box : HitBox = $HitBox
@onready var state_machine : EnemyStateMachine = $EnemyStateMachine

func _ready() -> void:
	state_machine.initialize( self )
	player = PlayerManager.player  # Make sure player is before enemies in scene tree to work
	hit_box.damaged.connect( _take_damage )
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta):
	move_and_slide()


func set_direction( _new_direction : Vector2 ) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false
	
	var direction_id : int = int( round( 
		( direction + cardinal_direction * 0.1 ).angle() 
		/ TAU * DIR_4.size() 
	))
	var new_dir = DIR_4[ direction_id ] # 0-3 directions
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	direction_changed.emit( new_dir ) # emits signal so attack direction will be correct
	
	if side_or_both_animations == false: # the below code reverses "side" animation direction should it exist
		sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	
	return true


func update_animation(state: String) -> void:
	var anim_name = state + "_" + anim_direction()
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	else:
		print("Warning: Animation not found: ", anim_name)


func anim_direction() -> String:
	if side_or_both_animations == false:
		if cardinal_direction == Vector2.DOWN:
			return "down"
		elif cardinal_direction == Vector2.UP:
			return "up"
		else:
			return "side"
	else:
		if cardinal_direction == Vector2.DOWN:
			return "down"
		elif cardinal_direction == Vector2.UP:
			return "up"
		elif cardinal_direction == Vector2.LEFT:
			return "left"
		elif cardinal_direction == Vector2.RIGHT:
			return "right"
	return "down"  # Fallback to a default direction


func _take_damage( hurt_box : HurtBox ) -> void:
	if invulnerable == true:
		return
	hp -= hurt_box.damage
	if hp > 0:
		enemy_damaged.emit( hurt_box )
	else:
		enemy_destroyed.emit( hurt_box )
