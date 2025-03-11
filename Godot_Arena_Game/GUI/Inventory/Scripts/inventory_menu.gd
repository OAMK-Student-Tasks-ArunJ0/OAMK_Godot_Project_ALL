# inventory_menu.gd
# Manages the inventory menu UI, including showing/hiding the menu, loading a game, and navigating to settings.

extends CanvasLayer

signal shown
signal hidden

@onready var audio_stream_player: AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var settings_menu = $Control/SettingsMenu
@onready var main_panel = $Control/HBoxContainer
@onready var button_load = $Control/HBoxContainer/Button_Load
@onready var item_description = $Control/ItemDescription
@onready var settings_button = $Control/HBoxContainer/Button_Settings
@onready var inventory_container: PanelContainer = $Control/PanelContainer
@onready var button_settings = $Control/HBoxContainer/Button_Settings
@onready var button_main_menu: Button = $Control/HBoxContainer/Button_Main_Menu
@onready var button_exit: Button = $Control/HBoxContainer/Button_Exit

const MAIN_MENU_LEVEL = "res://GUI/MainMenu/Scenes/main_menu.tscn"

var is_paused : bool = false

func _ready() -> void:
	# Initially hide the inventory menu.
	hide_inventory_menu()
	# Connect button signals.
	button_load.pressed.connect(_on_load_pressed)
	button_main_menu.pressed.connect(_on_main_menu_selected)
	settings_button.pressed.connect(_on_settings_pressed)
	settings_menu.back_pressed.connect(_on_settings_back)
	button_exit.pressed.connect(_on_exit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	# Toggle the inventory menu when the "pause" action is pressed.
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_inventory_menu()
		else:
			hide_inventory_menu()
		get_viewport().set_input_as_handled()

func show_inventory_menu() -> void:
	# Pause the game and show the inventory menu.
	get_tree().paused = true
	visible = true
	is_paused = true
	settings_menu.hide()
	inventory_container.show()
	main_panel.show()
	shown.emit()

func hide_inventory_menu() -> void:
	# Unpause the game and hide the inventory menu.
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()

func _on_load_pressed() -> void:
	# Load the game from the current save slot if the inventory menu is active.
	if is_paused == false:
		return
	SaveManager.load_game()
	await LevelManager.level_load_started
	hide_inventory_menu()

func _on_settings_pressed() -> void:
	# Show the settings menu and hide the inventory UI elements.
	inventory_container.hide()
	main_panel.hide()
	settings_menu.show()
	settings_menu.initialize_sliders()
	settings_menu.back_button.grab_focus()

func _on_settings_back() -> void:
	# Return to the inventory menu from settings.
	settings_menu.hide()
	inventory_container.show()
	main_panel.show()
	button_settings.grab_focus()

func _on_main_menu_selected() -> void:
	# Load the main menu scene.
	LevelManager.load_new_level(MAIN_MENU_LEVEL, "MainMenu", Vector2.ZERO)
	await LevelManager.level_load_started
	hide_inventory_menu()

func update_item_description(new_text: String) -> void:
	# Update the item description text in the UI.
	item_description.text = new_text

func play_audio(audio: AudioStream) -> void:
	# Play an audio clip from the inventory menu.
	audio_stream_player.stream = audio
	audio_stream_player.play()

func _on_exit_pressed() -> void:
	# Quit the game.
	get_tree().quit()
