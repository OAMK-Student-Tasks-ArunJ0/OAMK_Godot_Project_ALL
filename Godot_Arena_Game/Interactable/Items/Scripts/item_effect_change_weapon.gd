# item_effect_heal.gd
class_name ItemEffectChangeWeapon extends ItemEffect

@export var weapon : String = "knife"
@export var audio : AudioStream


func use() -> void:
	PlayerManager.player.ranged_weapon = weapon
	PauseMenu.play_audio( audio )
