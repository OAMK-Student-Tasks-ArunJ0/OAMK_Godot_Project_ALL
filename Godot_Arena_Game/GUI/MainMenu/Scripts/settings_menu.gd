# settings_menu.gd
# Manages the settings menu, allowing players to adjust audio levels.

extends Panel
signal back_pressed

@onready var sfx_slider = $VBoxContainer/SFXVolume/SFXSlider
@onready var music_slider = $VBoxContainer/MusicVolume/MusicSlider
@onready var master_slider = $VBoxContainer/MasterVolume/MasterSlider
@onready var back_button = $VBoxContainer/BackButton

func _ready() -> void:
	# Connect the back button and initialize sliders.
	back_button.pressed.connect(_on_back_pressed)
	initialize_sliders()
	# Connect slider value changes to update audio settings.
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	master_slider.grab_focus()

func _input(event: InputEvent) -> void:
	# Allow the player to cancel out of settings with the ui_cancel action.
	if visible:
		if event.is_action_pressed("ui_cancel"):
			_on_back_pressed()
			get_viewport().set_input_as_handled()

func initialize_sliders() -> void:
	# Load existing settings if available; otherwise, set default values.
	if FileAccess.file_exists(SaveManager.SAVE_PATH + "settings.sav"):
		SaveManager.load_settings()
		master_slider.value = SaveManager.settings_save.volume.master
		music_slider.value = SaveManager.settings_save.volume.music
		sfx_slider.value = SaveManager.settings_save.volume.sfx
	else:
		AudioManager.set_bus_volume("Master", 0.4)
		AudioManager.set_bus_volume("Music", 0.4)
		AudioManager.set_bus_volume("SFX", 0.4)
	
func _on_back_pressed() -> void:
	back_pressed.emit()

func _on_master_volume_changed(value: float) -> void:
	# Update the master volume and save the settings.
	AudioManager.set_bus_volume("Master", value)
	SaveManager.save_settings()

func _on_music_volume_changed(value: float) -> void:
	# Update the music volume and save the settings.
	AudioManager.set_bus_volume("Music", value)
	SaveManager.save_settings()

func _on_sfx_volume_changed(value: float) -> void:
	# Update the SFX volume and save the settings.
	AudioManager.set_bus_volume("SFX", value)
	SaveManager.save_settings()
