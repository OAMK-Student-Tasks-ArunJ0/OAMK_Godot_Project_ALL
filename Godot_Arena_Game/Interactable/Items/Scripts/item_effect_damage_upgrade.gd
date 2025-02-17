# item_effect_heal.gd
class_name ItemEffectDamageUpgrade extends ItemEffect


@export var melee_damage_upgrade : int = 2
@export var ranged_damage_upgrade : int = 1
@export var audio : AudioStream


func use() -> void:
	PlayerManager.player.update_damage( melee_damage_upgrade, ranged_damage_upgrade )
	PauseMenu.play_audio( audio )
