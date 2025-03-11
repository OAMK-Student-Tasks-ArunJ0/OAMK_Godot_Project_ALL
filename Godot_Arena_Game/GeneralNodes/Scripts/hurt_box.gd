# hurt_box.gd
# This node represents the "hurt" area of an object.
# It listens for other areas (HitBoxes) entering and then relays damage to them.

class_name HurtBox extends Area2D

@export var damage : int = 1  # The damage value this hurt box inflicts.
var has_hit : bool = false   # Flag to indicate if a collision has occurred.

func _ready() -> void:
	# Connect the area_entered signal to the hurt_area_entered function.
	area_entered.connect(hurt_area_entered)
	pass

# Initialize or update the damage value.
func init_damage(damage_amount : int) -> void:
	damage = damage_amount

# Called when another area enters this hurt box.
func hurt_area_entered(a : Area2D) -> void:
	# Check if the colliding area is a HitBox.
	if a is HitBox:
		# Call take_damage on the HitBox, passing this HurtBox.
		a.take_damage(self)
		# Set the flag to indicate a collision has occurred.
		has_hit = true
	pass
