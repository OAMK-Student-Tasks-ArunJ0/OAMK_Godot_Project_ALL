# item_effect_heal_upgrade.gd
# This effect upgrades the player's health.
# It increases both the player's maximum health and current health, and plays audio.

class_name ItemEffectHealUpgrade extends ItemEffect

@export var hp_upgrade_amount : int = 1
@export var audio : AudioStream

func use() -> void:
	# Increase the player's max HP.
	PlayerManager.player.update_max_hp(hp_upgrade_amount)
	# Heal the player by the same amount.
	PlayerManager.player.update_hp(hp_upgrade_amount)
	# Play the associated audio.
	InventoryMenu.play_audio(audio)
