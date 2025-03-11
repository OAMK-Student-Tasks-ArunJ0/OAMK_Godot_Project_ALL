# merchant.gd
# This script is attached to merchant characters in the world.
# It listens for the player entering or exiting the merchant area and,
# when the player interacts, shows the merchant menu.

extends Area2D

@export var merchant_data: MerchantData

func _ready() -> void:
	# Connect signals for when the player enters or exits the merchant area.
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	# When a Player enters the area, connect the interact_pressed signal.
	if body is Player:
		PlayerManager.interact_pressed.connect(_on_interact_pressed)

func _on_body_exited(body: Node) -> void:
	# Disconnect the interact_pressed signal when the Player leaves.
	if body is Player:
		PlayerManager.interact_pressed.disconnect(_on_interact_pressed)

func _on_interact_pressed() -> void:
	# When the player interacts, open the merchant menu with this merchant's data.
	MerchantUI.show_merchant_menu(merchant_data)
