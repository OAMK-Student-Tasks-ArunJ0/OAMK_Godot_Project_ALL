# persistent_data_handler.gd
# This node handles persistent data for its parent object.
# It allows the game to remember certain states (for example, whether a chest has been opened).

class_name PersistentDataHandler extends Node

# Signal emitted when the persistent data is loaded.
signal data_loaded

# Stores the persistent state value.
var value : bool = false

func _ready() -> void:
	# Retrieve the saved state value.
	get_value()
	pass

# Save the state by adding a persistent value for this node's unique name.
func set_value() -> void:
	SaveManager.add_persistent_value(_get_name())
	pass

# Retrieve the state value from the SaveManager.
func get_value() -> void:
	value = SaveManager.check_persistent_value(_get_name())
	# Notify listeners that the persistent data has been loaded.
	data_loaded.emit()
	pass

# Constructs a unique identifier based on the current scene and the parent node's name.
func _get_name() -> String:
	# Example: "res://levels/area01/01_dungeon.tscn/chest/PersistentDataHandler"
	return get_tree().current_scene.scene_file_path + "/" + get_parent().name + "/" + name
