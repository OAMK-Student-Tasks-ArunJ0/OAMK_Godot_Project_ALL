# main_menu.gd
# Handles the main menu interface and navigation between new game, continue, settings, and quit options.

extends CanvasLayer

@onready var new_game_button = $Control/MainPanel/NewGameButton
@onready var continue_button = $Control/MainPanel/ContinueButton
@onready var settings_button = $Control/MainPanel/SettingsButton
@onready var quit_button = $Control/MainPanel/ExitButton
@onready var save_slot_menu = $Control/SaveSlotMenu
@onready var settings_menu = $Control/SettingsMenu
@onready var main_panel: VBoxContainer = $Control/MainPanel
@onready var prologue = $Control/Prologue

func _ready() -> void:
	# Connect button signals for menu navigation.
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	save_slot_menu.back_pressed.connect(_on_slot_menu_back)
	save_slot_menu.prologue_started.connect(_on_prologue_started)
	
	prologue.new_game_started.connect(_on_start_new_game)
	
	settings_menu.back_pressed.connect(_on_settings_back)
	
	# Initially show the main panel and hide submenus.
	main_panel.visible = true
	save_slot_menu.visible = false
	settings_menu.visible = false
	prologue.visible = false
	
	# Enable or disable the continue button based on available saves.
	update_continue_button()
	
	# Set initial focus.
	new_game_button.grab_focus()

func update_continue_button() -> void:
	# Check all save slots to see if any saves exist.
	var any_save_exists = false
	for slot in range(1, 4):
		if SaveManager.does_save_exist(slot):
			any_save_exists = true
			break
	continue_button.disabled = !any_save_exists

func _on_continue_pressed() -> void:
	# Hide the main panel and show the save slot menu if a save exists.
	main_panel.visible = false
	var save_exists = false
	for slot in range(1, 4):
		if SaveManager.does_save_exist(slot):
			save_exists = true
			break
	
	if save_exists:
		save_slot_menu.set_mode("continue")
		save_slot_menu.visible = true
		save_slot_menu.slot1_button.grab_focus()
	else:
		# If no save exists, start a new game.
		_on_new_game_pressed()

func _on_new_game_pressed() -> void:
	# Start a new game by showing the save slot menu in "new" mode.
	main_panel.visible = false
	save_slot_menu.set_mode("new")
	save_slot_menu.visible = true
	save_slot_menu.slot1_button.grab_focus()

func _on_prologue_started() -> void:
	# Transition from the save slot menu to the prologue screen.
	main_panel.visible = false
	save_slot_menu.visible = false
	prologue.visible = true
	prologue.next_button.grab_focus()
	
func _on_start_new_game() -> void:
	# Begin the new game by loading the first level and setting up the player.
	PlayerManager.player.update_hp(99)
	LevelManager.load_new_level(SaveManager.FIRST_LEVEL, "PlayerSpawn", Vector2.ZERO)
	get_tree().paused = false
	PlayerManager.player_spawned = false
	PlayerManager.player.visible = true
	SaveManager.new_game()
	queue_free()  # Close the main menu.

func _on_settings_pressed() -> void:
	# Show the settings menu.
	main_panel.visible = false
	settings_menu.visible = true
	settings_menu.master_slider.grab_focus()

func _on_quit_pressed() -> void:
	# Quit the game.
	get_tree().quit()

func _on_slot_menu_back() -> void:
	# Return to the main menu from the save slot menu.
	save_slot_menu.visible = false
	main_panel.visible = true
	if save_slot_menu.mode == "new":
		new_game_button.grab_focus()
	else:
		continue_button.grab_focus()

func _on_settings_back() -> void:
	# Return to the main menu from the settings menu.
	settings_menu.visible = false
	main_panel.visible = true
	settings_button.grab_focus()
