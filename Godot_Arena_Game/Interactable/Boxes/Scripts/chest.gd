# chest.gd
# The chest holds an item and a quantity. Once opened, it gives its contents to the player.
@tool
class_name Chest extends Node2D

@export var item_data : ItemData : set = _set_item_data
@export var quantity : int = 1 : set = _set_quantity

# Tracks whether the chest has been opened already.
var is_opened : bool = false

# had some problems so implemented this with safe nodes
@onready var label = get_node_or_null("ItemSprite/Label")
@onready var item_sprite = get_node_or_null("ItemSprite") 
@onready var animation_player = get_node_or_null("AnimationPlayer")
@onready var interactable_area = get_node_or_null("Area2D")
@onready var is_open_data = get_node_or_null("PersistentData_IsOpen")

func _ready() -> void:
	# Check if all required nodes are available
	if not item_sprite or not animation_player or not is_open_data:
		print("Warning: Required nodes missing in Chest " + name)
		return
		
	# Update visuals based on item data and quantity.
	_update_texture()
	_update_label()
	
	# In editor mode, stop here.
	if Engine.is_editor_hint():
		return
		
	# Only connect signals if the nodes exist
	if interactable_area:
		interactable_area.area_entered.connect(_on_area_enter)
		interactable_area.area_exited.connect(_on_area_exit)
		
	# Connect the persistent data handler signal to set the chest state.
	is_open_data.data_loaded.connect(set_chest_state)
	
	# Initialize the chest state based on saved data.
	set_chest_state()

func set_chest_state() -> void:
	# Update the chest's open state from persistent data.
	is_opened = is_open_data.value
	if is_opened:
		animation_player.play("opened")
	else:
		animation_player.play("closed")

func player_interacted() -> void:
	# If the chest is already open, do nothing.
	if is_opened:
		return
	# Mark the chest as opened, save its state, and play the open animation.
	is_opened = true
	is_open_data.set_value()
	animation_player.play("open_chest")
	# If the chest has an item and a positive quantity, add it to the player's inventory.
	if item_data and quantity > 0:
		PlayerManager.INVENTORY_DATA.add_item(item_data, quantity)
	else:
		print("No Items in Chest! Chest Name: ", name)
	pass

func _on_area_enter(_a : Area2D) -> void:
	# When the player enters, connect the interact_pressed signal to allow chest interaction.
	PlayerManager.interact_pressed.connect(player_interacted)
	pass

func _on_area_exit(_a : Area2D) -> void:
	# When the player exits, disconnect the interact signal.
	PlayerManager.interact_pressed.disconnect(player_interacted)
	pass

func _set_item_data(value : ItemData) -> void:
	# Update the chest's item and refresh the texture.
	item_data = value
	_update_texture()
	pass

func _set_quantity(value : int) -> void:
	# Update the quantity and refresh the label.
	quantity = value
	_update_label()
	pass

func _update_texture() -> void:
	# If an item is set, update the sprite's texture accordingly.
	if item_data and item_sprite:
		item_sprite.texture = item_data.texture

func _update_label() -> void:
	# Update the label to show quantity if more than one; otherwise clear it.
	if label:
		if quantity <= 1:
			label.text = ""
		else:
			label.text = "x" + str(quantity)
