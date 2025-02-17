# inventory_ui.gd
class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GUI/Inventory/Scenes/inventory_slot.tscn")
var focus_index: int = 0
@export var data: InventoryData

func _ready() -> void:
	# Disconnect any existing connections first to prevent duplicates
	if PauseMenu.shown.is_connected(update_inventory):
		PauseMenu.shown.disconnect(update_inventory)
	if PauseMenu.hidden.is_connected(clear_inventory):
		PauseMenu.hidden.disconnect(clear_inventory)
		
	# Connect signals
	PauseMenu.shown.connect(update_inventory)
	PauseMenu.hidden.connect(clear_inventory)
	
	# Initial setup
	clear_inventory()
	
	# Connect to inventory data changes
	if data and data.changed.is_connected(on_inventory_changed):
		data.changed.disconnect(on_inventory_changed)
	if data:
		data.changed.connect(on_inventory_changed)

func clear_inventory() -> void:
	for child in get_children():
		child.queue_free()

func update_inventory(i: int = 0) -> void:
	# Clear existing slots first
	clear_inventory()
	
	# Only create slots if we have valid data
	if not data or not data.slots:
		return
		
	# Create new slots
	for slot_data in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = slot_data
		new_slot.focus_entered.connect(item_focused)
	
	# Set focus after a frame to ensure slots are ready
	await get_tree().process_frame
	if get_child_count() > i:
		get_child(i).grab_focus()

func item_focused() -> void:
	for i in get_child_count():
		if get_child(i).has_focus():
			focus_index = i
			return

func on_inventory_changed() -> void:
	var i = focus_index
	update_inventory(i)
