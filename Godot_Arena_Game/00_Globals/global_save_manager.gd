# global_save_manager.gd
# This script handles saving and loading game data including player state, scene information,
# inventory items, and settings (like audio levels). It supports multiple save slots and provides
# functions to create new games, continue from saves, and update persistent game data.

extends Node

# Constants for save management.
const SAVE_PATH = "user://"
const MAX_SAVE_SLOTS = 3

# Signals for save and load events.
signal game_loaded
signal game_saved
signal new_hud_message

# Holds the current save data and the active save slot.
var current_save : Dictionary
var current_save_slot : int = 1  # Default save slot
var save_slot_to_save : int = 1

# Constants for the first level and main menu scene paths.
const FIRST_LEVEL = "res://Levels/Maps/Forest_Tutorial/00_Forest.tscn"
const MAIN_MENU_LEVEL = "res://GUI/MainMenu/Scenes/main_menu.tscn"

# Template for a new game save data.
var new_game_save : Dictionary = {
	scene_path = "",
	player = {
		hp = 12,
		max_hp = 12,
		pos_x = 0,
		pos_y = 0,
		sword_damage = 2,
		sword_range = 1.0,
		ranged_damage = 1,
		ranged_weapon = "",
		dash_unlocked = false
	},
	items = [],
	persistence = [],
	quests = [],
}

# Default settings for audio volumes.
var settings_save : Dictionary = {
	volume = {
		master = 1,
		sfx = 1,
		music = 1
	}
}

func _ready() -> void:
	# Initialize current save with new game data if not already set.
	if current_save == null:
		current_save = new_game_save.duplicate(true)
	
	# Load saved settings (e.g., audio levels).
	load_settings()

# Returns the file path for a given save slot.
func get_save_file_path(slot: int) -> String:
	return SAVE_PATH + "save" + str(slot) + ".sav"

# Check if a save file exists for the specified slot.
func does_save_exist(slot: int) -> bool:
	return FileAccess.file_exists(get_save_file_path(slot))

# Get minimal information about the save file for UI display purposes.
func get_save_info(slot: int) -> Dictionary:
	if does_save_exist(slot):
		var file := FileAccess.open(get_save_file_path(slot), FileAccess.READ)
		var json := JSON.new()
		json.parse(file.get_line())
		var save_dict : Dictionary = json.get_data() as Dictionary
		
		# Return essential save data.
		return {
			"exists": true,
			"scene_path": save_dict.scene_path,
			"player_hp": save_dict.player.hp,
			"player_max_hp": save_dict.player.max_hp
		}
	return {"exists": false}

# Select a save slot and load its data into current_save.
func select_save_slot(slot: int) -> void:
	current_save_slot = slot
	
	if does_save_exist(slot):
		var file := FileAccess.open(get_save_file_path(slot), FileAccess.READ)
		var json := JSON.new()
		json.parse(file.get_line())
		current_save = json.get_data() as Dictionary
	else:
		# Use the new game template if no save exists.
		current_save = new_game_save.duplicate(true)

# Start a new game by resetting the save data for the chosen slot.
func new_game() -> void:
	select_save_slot(save_slot_to_save)
	current_save = new_game_save.duplicate(true)
	
	# Wait for the player instance to be ready.
	await get_tree().create_timer(0.5).timeout
	
	var p : Player = PlayerManager.player
	# Update player position in the save data.
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y
	
	# Set player stats and accessories.
	PlayerManager.set_health(current_save.player.hp, current_save.player.max_hp)
	PlayerManager.set_player_accessories(
		current_save.player.ranged_weapon, 
		current_save.player.dash_unlocked, 
		current_save.player.sword_range
	)
	PlayerManager.set_damage(
		current_save.player.sword_damage, 
		current_save.player.ranged_damage
	)
	
	# Save the new game state.
	save_game()
	
	new_hud_message.emit("New Game (Slot " + str(save_slot_to_save) + ")", 1.0)
	game_saved.emit()

# Continue a saved game from the specified slot.
func continue_game(slot: int) -> void:
	if does_save_exist(slot):
		select_save_slot(slot)
		load_game()
		new_hud_message.emit("Game Loaded (Slot " + str(slot) + ")", 1.0)
	else:
		new_hud_message.emit("No save found in Slot " + str(slot), 1.0)

# Save the current game state to a file.
func save_game() -> void:
	update_player_data()
	update_scene_path()
	update_item_data()
	
	var file := FileAccess.open(get_save_file_path(current_save_slot), FileAccess.WRITE)
	var save_json = JSON.stringify(current_save)
	file.store_line(save_json)
	
	new_hud_message.emit("Game Saved (Slot " + str(current_save_slot) + ")", 1.0)
	game_saved.emit()

# Load game state from the current_save dictionary.
func load_game() -> void:
	# Change to the saved level/scene.
	LevelManager.load_new_level(current_save.scene_path, "", Vector2.ZERO)
	
	await LevelManager.level_load_started
	
	# Set player's position and attributes from saved data.
	PlayerManager.set_player_position(Vector2(current_save.player.pos_x, current_save.player.pos_y))
	PlayerManager.set_health(current_save.player.hp, current_save.player.max_hp)
	PlayerManager.set_player_accessories(
		current_save.player.ranged_weapon, 
		current_save.player.dash_unlocked,
		current_save.player.sword_range
	)
	PlayerManager.set_damage(
		current_save.player.sword_damage, 
		current_save.player.ranged_damage
	)
	# Load inventory data from the save.
	PlayerManager.INVENTORY_DATA.parse_save_data(current_save.items)
	
	await LevelManager.level_loaded
	
	new_hud_message.emit("Game Loaded (Slot " + str(current_save_slot) + ")", 1.0)
	game_loaded.emit()

# Save current audio settings.
func save_settings() -> void:
	settings_save.volume.master = AudioManager.get_bus_volume("Master")
	settings_save.volume.music = AudioManager.get_bus_volume("Music")
	settings_save.volume.sfx = AudioManager.get_bus_volume("SFX")
	
	var file := FileAccess.open(SAVE_PATH + "settings.sav", FileAccess.WRITE)
	var save_json = JSON.stringify(settings_save)
	file.store_line(save_json)
	
	# Uncomment to show HUD message on settings save
	# new_hud_message.emit("Settings Saved")

# Load audio settings from the save file.
func load_settings() -> void:
	if FileAccess.file_exists(SaveManager.SAVE_PATH + "settings.sav"):
		var file := FileAccess.open(SAVE_PATH + "settings.sav", FileAccess.READ)
		var json := JSON.new()
		json.parse(file.get_line())
		var save_dict : Dictionary = json.get_data() as Dictionary
		settings_save = save_dict
		
		# Apply the loaded settings to the audio buses.
		AudioManager.set_bus_volume("Master", settings_save.volume.master)
		AudioManager.set_bus_volume("Music", settings_save.volume.music)
		AudioManager.set_bus_volume("SFX", settings_save.volume.sfx)
	else:
		# If no settings file exists, load default settings.
		SaveManager.load_settings()
	# Uncomment to show HUD message on settings load
	# new_hud_message.emit("Settings Loaded")

# Update the player data in the current save.
func update_player_data() -> void:
	var p : Player = PlayerManager.player
	current_save.player.hp = p.hp
	current_save.player.max_hp = p.max_hp
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y
	current_save.player.sword_damage = p.sword_damage
	current_save.player.ranged_damage = p.ranged_damage
	current_save.player.ranged_weapon = p.ranged_weapon
	current_save.player.dash_unlocked = p.dash_unlocked
	current_save.player.sword_range = p.sword_range

# Update the scene path in the current save.
func update_scene_path() -> void:
	var p : String = ""
	# Loop through root children to find the current level.
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
	current_save.scene_path = p

# Update the inventory item data in the current save.
func update_item_data() -> void:
	current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()

# Add a value to the persistent data array, if it does not already exist.
func add_persistent_value(value: String) -> void:
	if not current_save.has("persistence"):
		current_save["persistence"] = []
	
	if check_persistent_value(value) == false:
		current_save.persistence.append(value)
	pass

# Check if a given persistent value exists in the save.
func check_persistent_value(value: String) -> bool:
	if not current_save.has("persistence"):
		return false
	
	var p = current_save.persistence as Array
	return p.has(value)
