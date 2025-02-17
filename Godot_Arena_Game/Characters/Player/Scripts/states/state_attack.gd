class_name State_Attack extends State

var attacking : bool = false

@export_range(1,20,0.5) var decelerate_speed : float = 5.0

@onready var animation_player : AnimationPlayer = $"../../AnimationPlayer"
@onready var audio : AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

@onready var idle : State = $"../Idle"
@onready var walk : State = $"../Walk"
@onready var hurt_box : HurtBox = %AttackHurtBox

@export_category("Soufnds")
@export var sword_sounds: Array[AudioStream]  # Sword sounds array

## What happens when the player enters this State?
func enter() -> void:
	player.update_animation("attack")
	#attack_anim.play( "attack_" + player.anim_direction() )
	animation_player.animation_finished.connect( _end_attack )
	
	# print("sword damage is " + str(PlayerManager.player.attack_hurt_box.damage))
	audio.stream = sword_sounds[randi() % sword_sounds.size()]
	audio.pitch_scale = randf_range( 0.9, 1.1 )
	audio.play()
	
	attacking = true
	
	await get_tree().create_timer( 0.075 ).timeout
	if attacking:
		hurt_box.monitoring = true
	pass


## What happens when the player exits this State?
func exit() -> void:
	animation_player.animation_finished.disconnect( _end_attack )
	attacking = false
	hurt_box.monitoring = false
	pass


## What happens during the _process update in this State?
func process( _delta : float ) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null


## What happens during the _physics_process update in this State?
func physics( _delta : float ) -> State:
	return null


## What happens with input events in this State?
func handle_input( _event: InputEvent ) -> State:
	return null



func _end_attack( _newAnimName : String ) -> void:
	attacking = false
