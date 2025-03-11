# item_effect_heal.gd
# This effect heals the player by a specified amount and plays an audio cue.

class_name ItemEffectHeal extends ItemEffect

@export var heal_amount : int = 1
@export var audio : AudioStream

func use() -> void:
	# Heal the player.
	PlayerManager.player.update_hp(heal_amount)
	# Play the healing audio.
	InventoryMenu.play_audio(audio)
