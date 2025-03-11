# closed_door.gd
# A simple door that can open and close via animations. It displays a message when opened.

class_name ClosedDoor extends Node2D

var is_open : bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var door_message : String = "The Door has Opened!"

func _ready() -> void:
	# Initialization logic can be added here.
	pass

func open_door() -> void:
	# Play the opening animation and emit a HUD message.
	animation_player.play("open_door")
	SaveManager.new_hud_message.emit(door_message, 1.0)
	pass

func close_door() -> void:
	# Play the closing animation.
	animation_player.play("close_door")
	pass


func _on_body_sensor_deactivated() -> void:
	pass # Replace with function body.


func _on_enemy_death_count_2_enemies_dead() -> void:
	pass # Replace with function body.


func _on_enemy_death_count_4_enemies_dead() -> void:
	pass # Replace with function body.


func _on_enemy_death_count_3_enemies_dead() -> void:
	pass # Replace with function body.
