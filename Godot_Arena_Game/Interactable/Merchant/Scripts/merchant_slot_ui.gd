class_name MerchantSlotUI extends Button

signal slot_focused(slot_data: SlotData)
signal slot_pressed(slot_data: SlotData)

var slot_data: SlotData : set = set_slot_data

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func _ready() -> void:
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	pressed.connect(_on_pressed)
	clear_slot()

func set_slot_data(value: SlotData) -> void:
	slot_data = value
	if slot_data:
		texture_rect.texture = slot_data.item_data.texture
		label.text = str(slot_data.quantity) if slot_data.quantity > 1 else ""
	else:
		clear_slot()

func clear_slot() -> void:
	texture_rect.texture = null
	label.text = ""

func _on_focus_entered() -> void:
	slot_focused.emit(slot_data)

func _on_focus_exited() -> void:
	slot_focused.emit(null)

func _on_pressed() -> void:
	slot_pressed.emit(slot_data)
