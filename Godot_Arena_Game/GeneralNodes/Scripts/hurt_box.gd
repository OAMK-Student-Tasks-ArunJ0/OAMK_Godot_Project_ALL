class_name HurtBox extends Area2D

@export var damage : int = 1
var has_hit : bool = false  # Add this property

func _ready() -> void:
	area_entered.connect( hurt_area_entered )
	pass # Replace with function body.

func init_damage(damage_amount : int) -> void:
	damage = damage_amount

func hurt_area_entered( a : Area2D ) -> void:
	if a is HitBox:
		a.take_damage( self )
		has_hit = true  # Set has_hit to true when a collision occurs
	pass
