# item_effect_weapon_upgrade.gd
# This effect upgrades the player's weapon stats.
# It enhances melee damage, melee range, and ranged damage, then plays audio.

class_name ItemEffectWeaponUpgrade extends ItemEffect

@export var melee_damage_upgrade : int = 1
@export var melee_range_upgrade : float = 0.1
@export var ranged_damage_upgrade : int = 1
@export var audio : AudioStream

func use() -> void:
	# Update the player's weapon stats.
	PlayerManager.player.update_weapons(melee_range_upgrade, melee_damage_upgrade, ranged_damage_upgrade)
	# Play the upgrade audio.
	InventoryMenu.play_audio(audio)
