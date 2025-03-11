# prop_script.gd
# Represents a destructible prop that can take damage and play different animations based on its remaining health.

extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var health = 3  # The prop's health; also used to determine which animation to play.
@onready var hit_box: HitBox = $HitBox

func _ready() -> void:
	# Connect the hit box's damage signal to the _take_damage function.
	hit_box.damaged.connect(_take_damage)
	# Connect animation finished signal to check if the prop should be removed.
	animation_player.animation_finished.connect(_on_animation_finished)

func _take_damage(hurt_box : HurtBox) -> void:
	# Decrease health by the damage value from the hurt box.
	health -= hurt_box.damage
	# Play a damage animation if still alive.
	if health > 0:
		animation_player.play("prop_" + str(health))
	else:
		# Play the destruction animation if health is 0 or below.
		animation_player.play("prop_destroyed")

func _on_animation_finished(anim_name: String) -> void:
	# Once the destruction animation finishes, remove the prop.
	if anim_name == "prop_destroyed":
		queue_free()
