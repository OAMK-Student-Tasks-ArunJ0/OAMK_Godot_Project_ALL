class_name HitBox extends Area2D

signal damaged( hurt_box : HurtBox )

func _ready() -> void:
	pass # Replace with function body.



func take_damage( hurt_box : HurtBox ) -> void:
	damaged.emit( hurt_box )
