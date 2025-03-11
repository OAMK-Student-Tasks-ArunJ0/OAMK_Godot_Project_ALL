# merchant_slot_ui.gd
# This script represents a UI slot in the merchant menu.
# It displays an item and its quantity and emits signals when focused or pressed.

class_name MerchantSlotUI extends Button

# Signals emitted when the slot is focused or pressed.
signal slot_focused(slot_data: SlotData)
signal slot_pressed(slot_data: SlotData)

# Holds the slot data; setting it updates the UI.
var slot_data: SlotData : set = set_slot_data

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func _ready() -> void:
	# Connect UI signals for focus and press events.
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	pressed.connect(_on_pressed)
	# Clear any existing data on startup.
	clear_slot()

func set_slot_data(value: SlotData) -> void:
	# Update the slot's data and refresh its display.
	slot_data = value
	if slot_data:
		# Set the item's texture and display quantity (if more than 1).
		texture_rect.texture = slot_data.item_data.texture
		label.text = str(slot_data.quantity) if slot_data.quantity > 1 else ""
	else:
		clear_slot()

func clear_slot() -> void:
	# Clear the slot's UI elements.
	texture_rect.texture = null
	label.text = ""

func _on_focus_entered() -> void:
	# Emit the slot_focused signal with the current slot data.
	slot_focused.emit(slot_data)

func _on_focus_exited() -> void:
	# Emit the slot_focused signal with null when focus is lost.
	slot_focused.emit(null)

func _on_pressed() -> void:
	# Emit the slot_pressed signal with the current slot data when pressed.
	slot_pressed.emit(slot_data)
