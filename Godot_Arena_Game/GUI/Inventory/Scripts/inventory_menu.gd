# inventory_menu.gd
extends CanvasLayer

signal shown
signal hidden

@onready var audio_stream_player: AudioStreamPlayer = $Control/AudioStreamPlayer
@onready var settings_menu = $Control/SettingsMenu
@onready var main_panel = $Control/HBoxContainer
@onready var button_save = $Control/HBoxContainer/Button_Save
@onready var button_load = $Control/HBoxContainer/Button_Load
@onready var item_description = $Control/ItemDescription
@onready var settings_button = $Control/HBoxContainer/Button_Settings
@onready var inventory_container: PanelContainer = $Control/PanelContainer
@onready var button_settings = $Control/HBoxContainer/Button_Settings
@onready var button_exit: Button = $Control/HBoxContainer/Button_Exit


var is_paused : bool = false

func _ready() -> void:
	hide_pause_menu()
	button_save.pressed.connect(_on_save_pressed)
	button_load.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	settings_menu.back_pressed.connect(_on_settings_back)
	button_exit.pressed.connect(_on_exit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()

func show_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	settings_menu.hide()
	inventory_container.show()
	main_panel.show()
	shown.emit()

func hide_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()

func _on_save_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.save_game()
	hide_pause_menu()

func _on_load_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.load_game()
	await LevelManager.level_load_started
	hide_pause_menu()

func _on_settings_pressed() -> void:
	inventory_container.hide()
	main_panel.hide()
	settings_menu.show()
	settings_menu.initialize_sliders()
	settings_menu.back_button.grab_focus()

func _on_settings_back() -> void:
	settings_menu.hide()
	inventory_container.show()
	main_panel.show()
	button_settings.grab_focus()

func update_item_description(new_text: String) -> void:
	item_description.text = new_text

func play_audio(audio: AudioStream) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()

func _on_exit_pressed() -> void:
	get_tree().quit()
