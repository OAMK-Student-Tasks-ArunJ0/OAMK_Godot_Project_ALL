# enemy_ranged_attack_range.gd
# This Area2D defines the range within which an enemy can perform a ranged attack.
# It emits signals when the player enters or exits this range.

class_name EnemyRangedAttackRange extends Area2D

signal player_entered_ranged()
signal player_exited_ranged()

func _ready() -> void:
	body_entered.connect(_on_ranged_body_enter)
	body_exited.connect(_on_ranged_body_exit)

func _on_ranged_body_enter(_body: Node2D) -> void:
	if _body is Player:
		player_entered_ranged.emit()

func _on_ranged_body_exit(_body: Node2D) -> void:
	if _body is Player:
		player_exited_ranged.emit()
