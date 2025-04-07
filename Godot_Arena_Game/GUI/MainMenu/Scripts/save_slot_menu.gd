# save_slot_menu.gd
# Manages the save slot selection menu, allowing players to choose a slot for new games or to continue.

extends Panel

signal save_selected(slot)
signal back_pressed
signal tutorial_started

@onready var slot1_button = $VBoxContainer/Slot1
@onready var slot2_button = $VBoxContainer/Slot2
@onready var slot3_button = $VBoxContainer/Slot3
@onready var back_button = $VBoxContainer/BackButton
@onready var title_label: Label = $VBoxContainer/TitleLabel

# Mode can be "new" or "continue" depending on context.
var mode: String = "new"
# Constant for the tutorial scene path.
const TUTORIAL = "res://GUI/MainMenu/Scenes/tutorial.tscn"

func _ready() -> void:
	# Connect each slot button to its selection function.
	slot1_button.pressed.connect(func(): _on_slot_selected(1))
	slot2_button.pressed.connect(func(): _on_slot_selected(2))
	slot3_button.pressed.connect(func(): _on_slot_selected(3))
	back_button.pressed.connect(_on_back_pressed)
	
	update_slot_info()

func _input(event: InputEvent) -> void:
	# Allow the player to cancel the selection with the ui_cancel action.
	if visible:
		if event.is_action_pressed("ui_cancel"):
			_on_back_pressed()
			get_viewport().set_input_as_handled()

func update_slot_info() -> void:
	# Update the text on each slot button with save information.
	for slot in range(1, 4):
		var save_info = SaveManager.get_save_info(slot)
		var button
		match slot:
			1: button = slot1_button
			2: button = slot2_button
			3: button = slot3_button
		
		if save_info.exists:
			# Format the display text with scene name and player HP.
			var hp_text = str(save_info.player_hp) + "/" + str(save_info.player_max_hp) + " HP"
			var scene_name = save_info.scene_path.get_file().get_basename()
			button.text = "Slot " + str(slot) + ": " + scene_name + " - " + hp_text
		else:
			button.text = "Slot " + str(slot) + ": Empty"

func set_mode(new_mode: String) -> void:
	# Set the mode and update the title accordingly.
	mode = new_mode
	title_label.text = "Select Save Slot - " + mode.capitalize()
	slot1_button.grab_focus()

func _on_slot_selected(slot: int) -> void:
	if mode == "new":
		# Start a new game in the selected slot.
		start_tutorial(slot)
	else:
		# If continuing, check if the slot has a save.
		if SaveManager.does_save_exist(slot):
			continue_game(slot)
		else:
			# If empty, treat it as a new game.
			start_tutorial(slot)
	
	save_selected.emit(slot)

func start_tutorial(slot: int) -> void:
	# Set the chosen slot for the new game and emit the tutorial_started signal.
	SaveManager.save_slot_to_save = slot
	tutorial_started.emit()

func continue_game(slot: int) -> void:
	# Load the game from the selected save slot.
	SaveManager.select_save_slot(slot)
	SaveManager.load_game()
	get_tree().paused = false
	PlayerManager.player.visible = true
	queue_free()

func _on_back_pressed() -> void:
	back_pressed.emit()
