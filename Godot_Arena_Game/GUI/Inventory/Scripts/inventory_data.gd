# inventory_data.gd
class_name InventoryData extends Resource

@export var slots : Array[ SlotData ]

# Inventory data is controlled in this code such as item quantity and item removal when quantity reaches 0

func _init() -> void:
	connect_slots()
	pass


func add_item( item : ItemData, count : int = 1 ) -> bool:
	for s in slots:
		if s:
			if s.item_data == item:
				s.quantity += count
				return true
	
	for i in slots.size():
		if slots[ i ] == null:
			var new = SlotData.new()
			new.item_data = item
			new.quantity = count
			slots[ i ] = new
			new.changed.connect( slot_changed )
			return true
	
	print( "inventory was full!" )
	return false

func remove_item(item: ItemData, count: int = 1) -> bool:
	for s in slots:
		if s and s.item_data == item:
			# If the slot has enough quantity, remove the specified amount
			if s.quantity >= count:
				s.quantity -= count
				# If the quantity drops to 0, clear the slot
				if s.quantity <= 0:
					s.changed.disconnect(slot_changed)
					var index = slots.find(s)
					slots[index] = null
				emit_changed()
				return true
			else:
				# If the slot doesn't have enough quantity, return false
				print("Not enough quantity to remove!")
				return false
	
	# If the item isn't found in the inventory
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
	for s in slots:
		if s:
			s.changed.connect( slot_changed )


func slot_changed() -> void:
	for s in slots:
		if s:
			if s.quantity < 1:
				s.changed.disconnect( slot_changed )
				var index = slots.find( s ) # finding the slot number for slot
				slots[ index ] = null		# empties inventory slot
				emit_changed()
	pass


# inventory gathered into array so that it can be saved for inventory data
func get_save_data() -> Array:
	var item_save : Array = []
	for i in slots.size():
		item_save.append( item_to_save( slots[i] ) )
	return item_save


# Convert inventory items into dictionaries
func item_to_save( slot : SlotData ) -> Dictionary:
	var result = { item = "", quantity = 0 }
	if slot != null:
		result.quantity = slot.quantity
		if slot.item_data != null:
			result.item = slot.item_data.resource_path
	return result


# parse save
func parse_save_data( save_data : Array ) -> void:
	var array_size = slots.size()
	slots.clear()
	slots.resize( array_size )
	for i in save_data.size():
		slots[ i ] = item_from_save( save_data[ i ] )
	connect_slots()


# Converts saves Dictionary into Slotdata
func item_from_save( save_object : Dictionary ) -> SlotData:
	if save_object.item == "":
		return null
	var new_slot : SlotData = SlotData.new()
	new_slot.item_data = load( save_object.item )
	new_slot.quantity = int( save_object.quantity )
	return new_slot

func use_item( item : ItemData, count : int = 1 ) -> bool:
	for s in slots:
		if s:
			if s.item_data == item and s.quantity >= count:
				s.quantity -= count
				return true
	return false
