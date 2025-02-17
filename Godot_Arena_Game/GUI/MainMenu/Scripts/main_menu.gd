# Modified main_menu.gd
extends CanvasLayer

@onready var settings_menu = $Control/SettingsMenu
@onready var main_panel = $Control/MainPanel

const FIRST_LEVEL = "res://Levels/Maps/Area01/01_Dungeon.tscn"

@onready var continue_btn: Button = $Control/MainPanel/ContinueButton
@onready var new_game_btn: Button = $Control/MainPanel/NewGameButton
@onready var settings_btn: Button = $Control/MainPanel/SettingsButton
@onready var exit_btn: Button = $Control/MainPanel/ExitButton

func _ready() -> void:
	main_panel.show()
	settings_menu.hide()
	
	get_tree().paused = true
	PlayerManager.player.visible = false
	
	# Connect button signals
	
	continue_btn.pressed.connect(_on_continue_pressed)
	new_game_btn.pressed.connect(_on_new_game_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	settings_menu.back_pressed.connect(_on_settings_back)
	
	continue_btn.grab_focus()

func _on_continue_pressed() -> void:
	
	if FileAccess.file_exists(SaveManager.SAVE_PATH + "save.sav"):
		SaveManager.load_game()
		
		get_tree().paused = false
		PlayerManager.player.visible = true
		
		queue_free()
	else:
		_on_new_game_pressed()

func _on_new_game_pressed() -> void:
	
	LevelManager.load_new_level(FIRST_LEVEL, "PlayerSpawn", Vector2.ZERO)
	
	get_tree().paused = false
	PlayerManager.player_spawned = false
	PlayerManager.player.visible = true
	
	SaveManager.new_game()
	
	queue_free()

func _on_settings_pressed() -> void:
	main_panel.hide()
	settings_menu.show()
	settings_menu.back_button.grab_focus()

func _on_settings_back() -> void:
	settings_menu.hide()
	main_panel.show()
	continue_btn.grab_focus()

func _on_exit_pressed() -> void:
	get_tree().quit()
