# enemy_attack_range.gd
# This Area2D defines the range for a melee (or close-range) enemy attack.
# It emits signals when the player enters or exits the attack range.

class_name EnemyAttackRange extends Area2D

signal player_entered()
signal player_exited()

func _ready() -> void:
	body_entered.connect(_on_body_enter)
	body_exited.connect(_on_body_exit)

func _on_body_enter(_body: Node2D) -> void:
	if _body is Player:
		player_entered.emit()

func _on_body_exit(_body: Node2D) -> void:
	if _body is Player:
		player_exited.emit()
