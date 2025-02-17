# prop_script.gd
extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var health = 3 # Number of versions of the prop, also acts as health points
@onready var hit_box: HitBox = $HitBox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hit_box.damaged.connect(_take_damage)
	animation_player.animation_finished.connect(_on_animation_finished)

func _take_damage( hurt_box : HurtBox ) -> void:
	# Reduce health by the damage amount
	health -= hurt_box.damage
	
	if health > 0:
		# Play the corresponding damage animation based on current health
		animation_player.play("prop_" + str(health))
	else:
		# Play destruction animation when health is 0 or below
		animation_player.play("prop_destroyed")

func _on_animation_finished(anim_name: String) -> void:
	# When the destruction animation finishes, free the node
	if anim_name == "prop_destroyed":
		queue_free()
