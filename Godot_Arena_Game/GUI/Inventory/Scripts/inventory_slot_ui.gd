# inventory_slot_ui.gd
# Represents an individual inventory slot button in the UI.

class_name InventorySlotUI extends Button

# Holds the SlotData for this inventory slot.
var slot_data : SlotData : set = set_slot_data
# Stores this slot's index within the inventory grid.
var slot_index : int = -1

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func _ready() -> void:
	# Initialize the slot display.
	texture_rect.texture = null
	label.text = ""
	# Connect focus and pressed signals.
	focus_entered.connect(item_focused)
	focus_exited.connect(item_unfocused)
	pressed.connect(item_pressed)
	# Defer storing the slot's index until the node is ready.
	call_deferred("_store_slot_index")

func _store_slot_index() -> void:
	# Determine and store this slot's index within its parent.
	var parent = get_parent()
	if parent:
		for i in parent.get_child_count():
			if parent.get_child(i) == self:
				slot_index = i
				break

func set_slot_data(value : SlotData) -> void:
	# Set the slot data and update the UI accordingly.
	slot_data = value
	if slot_data == null:
		texture_rect.texture = null
		label.text = ""
		return
	texture_rect.texture = slot_data.item_data.texture
	label.text = str(slot_data.quantity)

func item_focused() -> void:
	# When focused, update the inventory menu description with this item's description.
	if slot_data != null and slot_data.item_data != null:
		InventoryMenu.update_item_description(slot_data.item_data.description)
	# Update the parent's focus index.
	var parent = get_parent()
	if parent is InventoryUI:
		parent.focus_index = slot_index

func item_unfocused() -> void:
	# Clear the description when focus is lost.
	InventoryMenu.update_item_description("")

func item_pressed() -> void:
	# Process item usage when the slot is pressed.
	if not slot_data or not slot_data.item_data:
		return
	var was_used = slot_data.item_data.use()
	if not was_used:
		return
	# Store the current slot index before updating.
	var current_slot = slot_index
	slot_data.quantity -= 1
	# Update the slot display.
	if slot_data.quantity <= 0:
		slot_data = null
	else:
		label.text = str(slot_data.quantity)
	# Trigger an update by emitting the changed signal.
	var parent = get_parent()
	if parent is InventoryUI and parent.data:
		parent.focus_index = current_slot
		parent.data.changed.emit()
