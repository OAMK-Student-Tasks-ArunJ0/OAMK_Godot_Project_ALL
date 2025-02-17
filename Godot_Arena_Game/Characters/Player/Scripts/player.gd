# player.gd
class_name Player extends CharacterBody2D

signal direction_changed( new_direction : Vector2 )
signal player_damaged( hurt_box : HurtBox )
signal player_dead( hurt_box : HurtBox )

const DIR_4 = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

var invulnerable : bool = false
var hp : int = 12
var max_hp : int = 12
var health_timer : float = 0.0
var player_cash : int = 150
var sword_damage : int = 2
var ranged_damage : int = 1

@export var health_regen_time : float = 5.0

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var effect_animation_player : AnimationPlayer = $EffectAnimationPlayer
@onready var hit_box : HitBox = $HitBox
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine : PlayerStateMachine = $StateMachine
@onready var audio : AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var attack_hurt_box : HurtBox = %AttackHurtBox
@onready var abilities: Abilities = $Abilities


# signal emitted so that hurtbox will be in right direction

func _ready() -> void:
	PlayerManager.player = self # Make sure player is before enemies in scene tree to work
	state_machine.Initialize(self)
	hit_box.damaged.connect( _take_damage )
	update_hp(99)
	attack_hurt_box.init_damage( sword_damage )
	
	pass

func _process(_delta: float) -> void:
	#var current_scene = get_tree().current_scene
	#if current_scene.scene_file_path == "res://MainMenu/Scenes/main_menu.tscn":
	
	# If we're in Dash state, ignore movement input
	health_timer -= _delta
	if health_timer < 0:
		if hp <= max_hp/4 or hp == 0:
			update_hp( +1 )
		health_timer = health_regen_time
	
	if state_machine.current_state is State_Dash:
		return
	
	# Otherwise, read movement input
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	pass

func _physics_process(_delta: float) -> void:
	move_and_slide()

func set_direction() -> bool:
	if direction == Vector2.ZERO:
		return false
	
	var direction_id : int = int( round( ( direction + cardinal_direction * 0.1 ).angle() / TAU * DIR_4.size() ) )
	
	var new_dir = DIR_4[ direction_id ] # 0-3 directions
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	direction_changed.emit( new_dir ) # emits signal so attack direction will be correct
	
	return true

func update_animation( state : String ) -> void:
	animation_player.play( state + "_" + anim_direction() )
	pass

func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	elif cardinal_direction == Vector2.RIGHT:
		return "right"
	else:
		return "down"
	# ^ above the right left animation system

func _take_damage( hurt_box : HurtBox ) -> void:
	if invulnerable == true:
		return
	update_hp( -hurt_box.damage )
	if hp > 0:
		player_damaged.emit( hurt_box )
	else:
		abilities.cooldown_funtion( "dash", 5.0 )
		SaveManager.new_hud_message.emit( "Resurrecting..." )
		player_dead.emit( hurt_box )
		
		#update_hp( 99 )
	pass

func update_hp( delta : int ) -> void:
	hp = clampi( hp + delta, 0, max_hp )
	PlayerHud.update_hp( hp, max_hp )
	pass

func update_max_hp( delta : int ) -> void:
	max_hp += delta
	PlayerHud.update_hp( hp, max_hp )
	pass

func update_damage( melee_upgrade : int, ranged_upgrade ) -> void:
	sword_damage += melee_upgrade
	ranged_damage += ranged_upgrade
	attack_hurt_box.init_damage( sword_damage )
	pass
	
func make_invulnerable( _duration : float = 1.0 ) -> void:
	invulnerable = true
	hit_box.monitoring = false
	
	await get_tree().create_timer( _duration ).timeout
	
	invulnerable = false
	hit_box.monitoring = true
	pass
