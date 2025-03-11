# item_effect_unlock_dash.gd
# This effect unlocks a player's ability (such as dash).
# After unlocking, it plays an audio cue.

class_name ItemEffectUnlockAbility extends ItemEffect

@export var ability_unlock_name : String = "dash_unlock"
@export var audio : AudioStream

func use() -> void:
	# Unlock the dash ability.
	PlayerManager.player.dash_unlocked = true
	# Play the associated audio.
	InventoryMenu.play_audio(audio)
