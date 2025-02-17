# merchant.gd
extends Area2D

@export var merchant_data: MerchantData

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body is Player:
		PlayerManager.interact_pressed.connect(_on_interact_pressed)

func _on_body_exited(body: Node) -> void:
	if body is Player:
		PlayerManager.interact_pressed.disconnect(_on_interact_pressed)

func _on_interact_pressed() -> void:
	MerchantUI.show_merchant_menu(merchant_data)
