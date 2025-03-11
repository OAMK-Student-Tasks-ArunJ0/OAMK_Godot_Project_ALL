# player_hud.gd
# Manages the player's HUD elements, including health bars, cooldown displays, and messages.

extends CanvasLayer

# Array to hold health bar nodes.
var health_bars: Array[HealthBar] = []

@onready var texture_rect : ColorRect = $Control/TextureRect
@onready var message_label : Label = $Control/TextureRect/Message_Label
@onready var hud_animation_player : AnimationPlayer = $Control/AnimationPlayer
@onready var cooldown_label : Label = $Control/Cooldown_Label
@onready var h_flow_container : HFlowContainer = $Control/HFlowContainer
@onready var death_screen : Control = $Control/DeathScreen

var message_time : float = 1.0
var message_timer : float = 0.0

func _ready() -> void:
	# Connect HUD message signal.
	SaveManager.new_hud_message.connect(new_hud_message)
	# Hide the death screen if it is not paused.
	if death_screen.is_paused == false:
		death_screen.hide_death_screen()
	# Find and store any HealthBar nodes under the HFlowContainer.
	for child in h_flow_container.get_children():
		if child is HealthBar:
			health_bars.append(child)
			child.visible = false

func _process(_delta: float) -> void:
	var cooldown_text = ""
	
	# Update dash cooldown if active.
	if PlayerManager.player.abilities.dash_timer > 0:
		cooldown_text += "Dash CD: %.1f" % PlayerManager.player.abilities.dash_timer
	
	# Update ranged cooldown if active.
	if PlayerManager.player.abilities.ranged_timer > 0:
		if cooldown_text != "":
			cooldown_text += "\n"  # Add a line break between cooldown texts.
		cooldown_text += "Ranged CD: %.1f" % PlayerManager.player.abilities.ranged_timer
	
	cooldown_label.text = cooldown_text
	
	# Count down the HUD message timer and hide the message when time expires.
	if texture_rect.visible:
		message_timer -= _delta
		if message_timer <= 0:
			hud_animation_player.play("message_animation")
			
func update_hp(hp: int, max_hp: int) -> void:
	# Update the maximum number of health bars and then update each bar's display.
	update_max_hp(max_hp)
	for i in health_bars.size():
		update_healthbar(i, hp)

func update_healthbar(index: int, hp: int) -> void:
	# Calculate the displayed value for the health bar.
	var value: int = clampi(hp - index * 2, 0, 2)
	health_bars[index].value = value

func update_max_hp(max_hp: int) -> void:
	# Determine the required number of health bars based on max health.
	var health_bar_count: int = roundi(max_hp * 0.5)

	# Create additional health bars if needed.
	while health_bars.size() < health_bar_count:
		var new_health_bar = preload("res://GUI/HUD/Scenes/health_bar.tscn").instantiate()
		h_flow_container.add_child(new_health_bar)
		health_bars.append(new_health_bar)
		new_health_bar.visible = false  # Initially hidden

	# Set visibility for each health bar based on the maximum health.
	for i in health_bars.size():
		health_bars[i].visible = i < health_bar_count

func new_hud_message(message_text : String, msg_time : float) -> void:
	# Display a new HUD message for the specified duration.
	message_label.text = message_text
	texture_rect.visible = true
	message_timer = msg_time
