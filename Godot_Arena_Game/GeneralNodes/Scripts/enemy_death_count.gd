class_name EnemyDeathCount extends Node

signal enemies_dead

func _ready() -> void:
	child_exiting_tree.connect( _on_enemy_destroyed )
	pass

func _on_enemy_destroyed( level_node : Node2D ) -> void:
	if level_node is Enemy:
		# when counting the enemies using child_exiting means that the last time it is counted it is 1
		if enemy_count() <= 1:
			enemies_dead.emit()
			print("Enemies in level Dead")
	pass

func enemy_count() -> int:
	var dead_enemies_count : int = 0
	
	for enem_count_child in get_children():
		if enem_count_child is Enemy:
			dead_enemies_count += 1
	
	return dead_enemies_count
