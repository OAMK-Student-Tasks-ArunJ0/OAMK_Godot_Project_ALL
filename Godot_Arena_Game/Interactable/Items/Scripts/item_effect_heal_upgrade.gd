# item_effect_heal.gd
class_name ItemEffectHealUpgrade extends ItemEffect

@export var hp_upgrade_amount : int = 1
@export var audio : AudioStream


func use() -> void:
	PlayerManager.player.update_max_hp( hp_upgrade_amount )
	PlayerManager.player.update_hp( hp_upgrade_amount )
	PauseMenu.play_audio( audio )
