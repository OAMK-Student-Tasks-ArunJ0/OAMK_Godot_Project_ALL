# item_data.gd
# This resource represents an in-game item.
# It contains properties like name, description, texture, effects, and its sell value.

class_name ItemData extends Resource

@export var name : String = ""
@export_multiline var description : String = ""
@export var texture : Texture2D

@export_category("Item Use Effects")
@export var effects : Array[ItemEffect]
@export var sell_value : int = 5

func use() -> bool:
	# If no effects are defined, the item cannot be used.
	if effects.size() == 0:
		return false
	
	# Execute all defined effects.
	for e in effects:
		if e:
			e.use()
	return true
