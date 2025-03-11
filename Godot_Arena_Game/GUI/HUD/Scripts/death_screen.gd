# death_screen.gd
# Manages the death screen UI, including buttons for reloading the last save, returning to the main menu, or quitting the game.

extends Control

@onready var load_last_save: Button = $CenterContainer/DeathPanel/MarginContainer/VBoxContainer/LoadLastSave
@onready var main_menu: Button = $CenterContainer/DeathPanel/MarginContainer/VBoxContainer/MainMenu
@onready var quit_game: Button = $CenterContainer/DeathPanel/MarginContainer/VBoxContainer/QuitGame

# Flag to indicate whether the death screen is active (paused).
var is_paused : bool = false

func _ready() -> void:
	# Connect button signals to their respective functions.
	load_last_save.pressed.connect(_on_last_save_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)
	quit_game.pressed.connect(_on_quit_game_pressed)
	# Set initial focus to the load last save button.
	load_last_save.grab_focus()

func _on_last_save_pressed() -> void:
	# Only process if the death screen is active.
	if is_paused == false:
		return
	SaveManager.load_game()
	await LevelManager.level_load_started
	hide_death_screen()

func _on_main_menu_pressed() -> void:
	# Load the main menu scene.
	LevelManager.load_new_level(SaveManager.MAIN_MENU_LEVEL, "MainMenu", Vector2.ZERO)
	await LevelManager.level_load_started
	hide_death_screen()

func _on_quit_game_pressed() -> void:
	# Quit the game.
	get_tree().quit()

func show_death_screen() -> void:
	# Display the death screen and pause the game.
	PlayerHud.cooldown_label.visible = false
	get_tree().paused = true
	visible = true
	is_paused = true

func hide_death_screen() -> void:
	# Hide the death screen and resume the game.
	PlayerHud.cooldown_label.visible = true
	get_tree().paused = false
	visible = false
	is_paused = false
