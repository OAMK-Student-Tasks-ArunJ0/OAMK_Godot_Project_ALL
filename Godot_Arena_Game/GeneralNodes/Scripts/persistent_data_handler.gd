class_name PersistentDataHandler extends Node
# This scene keeps its parents state for gamedata such as if chest is opened 

signal data_loaded
var value : bool = false


func _ready() -> void:
	get_value()
	pass


func set_value() -> void:
	SaveManager.add_persistent_value( _get_name() )
	pass


func get_value() -> void:
	value = SaveManager.check_persistent_value( _get_name() )
	data_loaded.emit()
	pass


func _get_name() -> String:
	# Gets the scenes path:  "res://levels/area01/01_dungeon.tscn/treasurechest/PersistentDataHandler"
	return get_tree().current_scene.scene_file_path + "/" + get_parent().name + "/" + name
