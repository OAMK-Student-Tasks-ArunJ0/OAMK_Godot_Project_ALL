# inventory_data.gd
# Manages the player's inventory data, including adding, removing, and saving items.

class_name InventoryData extends Resource

@export var slots : Array[SlotData]

func _init() -> void:
	# Connect change signals for each slot in the inventory.
	connect_slots()
	pass

func add_item(item : ItemData, count : int = 1) -> bool:
	# Check if the item already exists in the inventory.
	for s in slots:
		if s:
			if s.item_data == item:
				s.quantity += count
				return true
	
	# Find an empty slot to add the new item.
	for i in slots.size():
		if slots[i] == null:
			var new = SlotData.new()
			new.item_data = item
			new.quantity = count
			slots[i] = new
			new.changed.connect(slot_changed)
			return true
	
	print("inventory was full!")
	return false

func remove_item(item: ItemData, count: int = 1) -> bool:
	# Remove a specified quantity of an item.
	for s in slots:
		if s and s.item_data == item:
			if s.quantity >= count:
				s.quantity -= count
				# Clear the slot if quantity drops to zero.
				if s.quantity <= 0:
					s.changed.disconnect(slot_changed)
					var index = slots.find(s)
					slots[index] = null
				emit_changed()
				return true
			else:
				print("Not enough quantity to remove!")
				return false
	print("Item not found in inventory!")
	return false

func get_item_quantity(item: ItemData) -> int:
	var total_quantity : int = 0
	for s in slots:
		if s and s.item_data == item:
			total_quantity += s.quantity
	return total_quantity 

func get_inventory_number(item: ItemData) -> int:
	var inventory_number : int = 0
	for s in slots:
		if s and s.item_data == item:
			return inventory_number
		else:
			inventory_number += 1
	return 0

func connect_slots() -> void:
	# Connect each non-null slot's change signal.
	for s in slots:
		if s:
			s.changed.connect(slot_changed)

func slot_changed() -> void:
	# Clear any slots that have a quantity less than 1.
	for s in slots:
		if s:
			if s.quantity < 1:
				s.changed.disconnect(slot_changed)
				var index = slots.find(s)
				slots[index] = null
				emit_changed()
	pass

func get_save_data() -> Array:
	# Convert inventory slots into an array of dictionaries for saving.
	var item_save : Array = []
	for i in slots.size():
		item_save.append(item_to_save(slots[i]))
	return item_save

func item_to_save(slot : SlotData) -> Dictionary:
	# Convert a slot's data into a savable dictionary.
	var result = { item = "", quantity = 0 }
	if slot != null:
		result.quantity = slot.quantity
		if slot.item_data != null:
			result.item = slot.item_data.resource_path
	return result

func parse_save_data(save_data : Array) -> void:
	# Parse saved inventory data back into slots.
	var array_size = slots.size()
	slots.clear()
	slots.resize(array_size)
	for i in save_data.size():
		slots[i] = item_from_save(save_data[i])
	connect_slots()

func item_from_save(save_object : Dictionary) -> SlotData:
	# Convert a save dictionary back into a SlotData instance.
	if save_object.item == "":
		return null
	var new_slot : SlotData = SlotData.new()
	new_slot.item_data = load(save_object.item)
	new_slot.quantity = int(save_object.quantity)
	return new_slot

func use_item(item : ItemData, count : int = 1) -> bool:
	# Use an item by decreasing its quantity.
	for s in slots:
		if s:
			if s.item_data == item and s.quantity >= count:
				s.quantity -= count
				return true
	return false
