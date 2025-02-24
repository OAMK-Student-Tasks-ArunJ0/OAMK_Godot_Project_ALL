extends CanvasLayer

var health_bars: Array[HealthBar] = []

@onready var message_label: Label = $Control/Message_Label
@onready var hud_animation_player: AnimationPlayer = $Control/AnimationPlayer
@onready var cooldown_label: Label = $Control/Cooldown_Label

func _ready() -> void:
	SaveManager.new_hud_message.connect(new_hud_message)
	for child in $Control/HFlowContainer.get_children():
		if child is HealthBar:
			health_bars.append(child)
			child.visible = false

func _process(_delta: float) -> void:
	var cooldown_text = ""
	
	# Check dash cooldown
	if PlayerManager.player.abilities.dash_timer > 0:
		cooldown_text += "Dash CD: %.1f" % PlayerManager.player.abilities.dash_timer
	
	# Check ranged cooldown
	if PlayerManager.player.abilities.ranged_timer > 0:
		if cooldown_text != "":
			cooldown_text += "\n"  # Add line break if we already have dash text
		cooldown_text += "Ranged CD: %.1f" % PlayerManager.player.abilities.ranged_timer
	
	cooldown_label.text = cooldown_text

func update_hp(hp: int, max_hp: int) -> void:
	update_max_hp(max_hp)
	for i in max_hp:
		update_healthbar(i, hp)

func update_healthbar(index: int, hp: int) -> void:
	var value: int = clampi(hp - index * 2, 0, 2)
	health_bars[index].value = value

func update_max_hp(max_hp: int) -> void:
	var health_bar_count: int = roundi(max_hp * 0.5)
	for i in health_bars.size():
		if i < health_bar_count:
			health_bars[i].visible = true
		else:
			health_bars[i].visible = false

func new_hud_message(message_text: String) -> void:
	message_label.text = message_text
	hud_animation_player.play("message_animation")
