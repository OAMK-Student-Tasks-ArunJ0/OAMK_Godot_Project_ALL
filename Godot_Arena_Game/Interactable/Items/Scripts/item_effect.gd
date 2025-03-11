# item_effect.gd
# Base class for item effects.
# Specific effects should extend this class and implement the use() method.

class_name ItemEffect extends Resource

@export var use_description : String

func use() -> void:
	# To be implemented by subclasses.
	pass
