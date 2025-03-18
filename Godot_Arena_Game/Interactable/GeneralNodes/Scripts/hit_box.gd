# hit_box.gd
# This node represents the "hit" area for an object.
# It emits a signal when it takes damage from a colliding HurtBox.

class_name HitBox extends Area2D

# Signal emitted when damage is applied; passes the HurtBox that caused the damage.
signal damaged(hurt_box : HurtBox)

func _ready() -> void:
	# Initialization can be added here if needed.
	pass

# Called to apply damage using the provided HurtBox.
func take_damage(hurt_box : HurtBox) -> void:
	# Emit the damaged signal so other nodes can respond.
	damaged.emit(hurt_box)
