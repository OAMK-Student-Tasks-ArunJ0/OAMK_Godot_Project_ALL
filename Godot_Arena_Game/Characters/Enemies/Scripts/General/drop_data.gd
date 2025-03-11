# drop_data.gd
# This resource defines data for item drops from enemies.
# It includes the item, drop probability, and a range for the quantity dropped.

class_name DropData extends Resource

@export var item: ItemData
@export_range(0, 100, 1, "suffix:%") var probability: float = 100
@export_range(1, 10, 1, "suffix:items") var min_amount: int = 1
@export_range(1, 10, 1, "suffix:items") var max_amount: int = 1

func get_drop_count() -> int:
	# Use probability to decide whether to drop an item.
	if randf_range(0, 100) >= probability:
		return 0
	# Return a random count between min and max amounts.
	return randi_range(min_amount, max_amount)
