# item_effect_change_weapon.gd
# This item effect changes the player's weapon.
# It sets the player's ranged weapon to a new value and plays an audio cue.

class_name ItemEffectChangeWeapon extends ItemEffect

@export var weapon : String = "knife"
@export var audio : AudioStream

func use() -> void:
	# Update the player's weapon.
	PlayerManager.player.ranged_weapon = weapon
	# Play the associated audio.
	InventoryMenu.play_audio(audio)
