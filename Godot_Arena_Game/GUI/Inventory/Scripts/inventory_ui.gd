# inventory_ui.gd
# Handles the overall inventory UI display, updating slot nodes and managing focus.

class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GUI/Inventory/Scenes/inventory_slot.tscn")

var focus_index: int = 0
var slot_count: int = 0
var is_updating: bool = false

@export var data: InventoryData

func _ready() -> void:
	# Disconnect previous signal connections to avoid duplicates.
	if InventoryMenu.shown.is_connected(update_inventory):
		InventoryMenu.shown.disconnect(update_inventory)
	if InventoryMenu.hidden.is_connected(clear_inventory):
		InventoryMenu.hidden.disconnect(clear_inventory)
	# Connect signals for showing/hiding the inventory.
	InventoryMenu.shown.connect(update_inventory)
	InventoryMenu.hidden.connect(clear_inventory)
	# Clear any existing inventory display.
	clear_inventory()
	# Connect to inventory data changes.
	if data and data.changed.is_connected(on_inventory_changed):
		data.changed.disconnect(on_inventory_changed)
	if data:
		data.changed.connect(on_inventory_changed)

func clear_inventory() -> void:
	# Remove all inventory slot nodes.
	for child in get_children():
		child.queue_free()
	slot_count = 0

func update_inventory(i: int = 0) -> void:
	# Prevent recursive updates.
	if is_updating:
		return
	is_updating = true
	# Clear current inventory UI.
	clear_inventory()
	# Return early if there is no valid data.
	if not data or not data.slots:
		is_updating = false
		return
	# Instantiate inventory slot nodes for each slot.
	for slot_data in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = slot_data
		slot_count += 1
	# Set focus index and update focus.
	focus_index = clamp(i, 0, max(0, slot_count - 1))
	call_deferred("_set_focus_deferred")
	is_updating = false

func _set_focus_deferred() -> void:
	# Wait one frame to ensure nodes are ready, then set focus on the appropriate slot.
	await get_tree().process_frame
	if slot_count == 0:
		return
	focus_index = clamp(focus_index, 0, slot_count - 1)
	if slot_count > 0 and is_node_ready() and is_visible_in_tree():
		# Update slot indices.
		for i in get_child_count():
			var slot = get_child(i)
			if slot is InventorySlotUI:
				slot.slot_index = i
		get_child(focus_index).grab_focus()

func on_inventory_changed() -> void:
	# Save the current focus, update the inventory UI, and restore focus.
	var saved_focus = focus_index
	update_inventory(saved_focus)
