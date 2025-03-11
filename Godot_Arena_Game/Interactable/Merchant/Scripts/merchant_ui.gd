# merchant_ui.gd
# This script manages the merchant menu UI.
# It displays the merchant’s inventory, the player’s inventory,
# updates the points display, and handles item buying and selling.

extends CanvasLayer

@onready var points_label: Label = $Control/PointsContainer/Points
@onready var item_description: Label = $Control/ItemDescription
@onready var merchant_inventory: Control = $Control/MerchantInventory
@onready var player_inventory: Control = $Control/PlayerInventory
@onready var audio_player: AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var button_close: Button = $Control/Button_close

# Holds the current merchant data while the menu is active.
var current_merchant: MerchantData
# The currency item used to represent money.
var money_item : ItemData = preload("res://Interactable/Items/Resources/gem.tres")

func _ready() -> void:
	# Hide the merchant UI on startup.
	hide()
	# Ensure the game is not paused.
	if not get_tree().paused:
		get_tree().paused = false
	button_close.pressed.connect(_on_close_pressed)
	
	# Connect signals for each merchant slot.
	for slot in merchant_inventory.get_node("MarginContainer/GridContainer").get_children():
		slot.slot_focused.connect(_on_merchant_slot_focused)
		slot.slot_pressed.connect(_on_merchant_slot_pressed)
	
	# Connect signals for each player inventory slot.
	for slot in player_inventory.get_node("MarginContainer/GridContainer").get_children():
		slot.slot_focused.connect(_on_player_slot_focused)
		slot.slot_pressed.connect(_on_player_slot_pressed)

func show_merchant_menu(merchant_data: MerchantData) -> void:
	# Set the current merchant and display the merchant menu.
	current_merchant = merchant_data
	visible = true
	get_tree().paused = true
	
	update_points_display()
	setup_merchant_inventory()
	setup_player_inventory()
	
	# Set initial focus on the first merchant slot.
	await get_tree().process_frame
	var first_slot = merchant_inventory.get_node("MarginContainer/GridContainer").get_child(0)
	if first_slot:
		first_slot.grab_focus()

func hide_merchant_menu() -> void:
	# Hide the merchant UI and resume game time.
	visible = false
	get_tree().paused = false
	current_merchant = null
	clear_description()

func update_points_display() -> void:
	# Update the points display based on the player's current money.
	points_label.text = str(PlayerManager.INVENTORY_DATA.get_item_quantity(money_item))

func setup_merchant_inventory() -> void:
	# Populate the merchant inventory slots with data.
	var merchant_slots = merchant_inventory.get_node("MarginContainer/GridContainer").get_children()
	var inventory_data = current_merchant.inventory
	
	for i in range(merchant_slots.size()):
		var slot = merchant_slots[i]
		if i < inventory_data.slots.size():
			slot.set_slot_data(inventory_data.slots[i])
		else:
			slot.set_slot_data(null)

func setup_player_inventory() -> void:
	# Populate the player inventory slots with data.
	var player_slots = player_inventory.get_node("MarginContainer/GridContainer").get_children()
	var inventory_data = PlayerManager.INVENTORY_DATA
	
	for i in range(player_slots.size()):
		var slot = player_slots[i]
		if i < inventory_data.slots.size():
			slot.set_slot_data(inventory_data.slots[i])
		else:
			slot.set_slot_data(null)

func clear_description() -> void:
	# Clear the item description text.
	item_description.text = ""

func _on_merchant_slot_focused(slot_data: SlotData) -> void:
	# When a merchant slot is focused, display the item's description and its buy price.
	if slot_data and slot_data.item_data:
		var item = slot_data.item_data
		var buy_price = item.sell_value
		item_description.text = "%s\nBuy Price: %d gold" % [item.description, buy_price]
	else:
		clear_description()

func _on_player_slot_focused(slot_data: SlotData) -> void:
	# When a player inventory slot is focused, display the item's description and its sell price.
	if slot_data and slot_data.item_data:
		var item = slot_data.item_data
		# Calculate the sell price using the merchant's sell value multiplier.
		var sell_price = max(int(item.sell_value * current_merchant.sell_value_multiplier), 1)
		item_description.text = "%s\nSell Price: %d gold" % [item.description, sell_price]
	else:
		clear_description()

func _on_merchant_slot_pressed(slot_data: SlotData) -> void:
	# Handle buying an item from the merchant.
	if not slot_data or not slot_data.item_data:
		return
	
	var item = slot_data.item_data
	var buy_price = item.sell_value
	var inv_num : int = current_merchant.inventory.get_inventory_number(item)
	
	# Check if the player has enough money.
	if PlayerManager.INVENTORY_DATA.get_item_quantity(money_item) >= buy_price:
		# Add the item to the player's inventory and remove money.
		if PlayerManager.INVENTORY_DATA.add_item(item, 1):
			PlayerManager.INVENTORY_DATA.remove_item(money_item, buy_price)
			update_points_display()
			audio_player.play()
			setup_player_inventory()
	
	# Refocus the slot after the transaction.
	refocus_slot(merchant_inventory, inv_num)

func _on_player_slot_pressed(slot_data: SlotData) -> void:
	# Handle selling an item from the player's inventory.
	if not slot_data or not slot_data.item_data:
		return
		
	var item = slot_data.item_data
	# Calculate the sell price.
	var sell_price : int = max(int(item.sell_value * current_merchant.sell_value_multiplier), 1)
	var inv_num : int = PlayerManager.INVENTORY_DATA.get_inventory_number(item)
	
	# Add money to the player's inventory and reduce item quantity.
	PlayerManager.INVENTORY_DATA.add_item(money_item, sell_price)
	slot_data.quantity -= 1
		
	update_points_display()
	audio_player.play()
	setup_player_inventory()
	
	# Refocus the slot only if the item was completely sold.
	refocus_slot(player_inventory, inv_num)

func refocus_slot(inventory: Control, inv_num: int) -> void:
	# Wait a frame and then set focus to the slot at the given index.
	await get_tree().process_frame
	var first_slot = inventory.get_node("MarginContainer/GridContainer").get_child(inv_num)
	if first_slot:
		first_slot.grab_focus()
		
func _on_close_pressed() -> void:
	# Hide the merchant menu when the close button is pressed.
	hide_merchant_menu()

func _unhandled_input(event: InputEvent) -> void:
	# If the "pause" action is triggered while the merchant menu is visible, close it.
	if event.is_action_pressed("pause") and visible:
		get_viewport().set_input_as_handled()
		hide_merchant_menu()
