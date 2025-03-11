# merchant_data.gd
# A resource that holds merchant-specific properties such as the sell value multiplier
# and the merchant's inventory data.

@tool
class_name MerchantData extends Resource

# Multiplier used to determine the price when a player sells an item.
@export var sell_value_multiplier: float = 0.5
# The merchant's inventory data.
@export var inventory: InventoryData
