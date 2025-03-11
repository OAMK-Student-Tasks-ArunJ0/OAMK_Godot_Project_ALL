# slot_data.gd
# Represents a single inventory slot's data, including the item and its quantity.

class_name SlotData extends Resource

@export var item_data : ItemData
@export var quantity : int = 0 : set = set_quantity

func set_quantity(value : int):
	quantity = value
	# Emit a change signal if the quantity drops below 1.
	if quantity < 1:
		emit_changed()
