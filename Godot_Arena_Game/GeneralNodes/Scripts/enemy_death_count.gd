# enemy_death_count.gd
# This node listens for child nodes exiting the scene tree (i.e. when an enemy is destroyed).
# It counts the remaining enemies and emits a signal when the last enemy has been removed.

class_name EnemyDeathCount extends Node

# Signal emitted when all enemies in the level have been destroyed.
signal enemies_dead

func _ready() -> void:
	# Connect the child_exiting_tree signal so that _on_enemy_destroyed is called when a child is removed.
	child_exiting_tree.connect(_on_enemy_destroyed)
	pass

# Called when a child node is about to exit the tree.
func _on_enemy_destroyed(level_node : Node2D) -> void:
	# Check if the exiting node is an Enemy.
	if level_node is Enemy:
		# Count the number of enemies still present.
		# When only one enemy is left (i.e. the one being removed), consider all enemies dead.
		if enemy_count() <= 1:
			enemies_dead.emit()
			print("Enemies in level Dead")
	pass

# Returns the number of enemy nodes that are still children of this node.
func enemy_count() -> int:
	var dead_enemies_count : int = 0
	
	for child in get_children():
		if child is Enemy:
			dead_enemies_count += 1
	
	return dead_enemies_count
