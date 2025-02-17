# settings_menu.gd
extends Panel

signal back_pressed

@onready var sfx_slider = $VBoxContainer/SFXVolume/SFXSlider
@onready var music_slider = $VBoxContainer/MusicVolume/MusicSlider
@onready var master_slider = $VBoxContainer/MasterVolume/MasterSlider
@onready var back_button = $VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	
	# Initialize slider values
	initialize_sliders()
	
	
	# Connect slider signals
	master_slider.value_changed.connect(_on_master_volume_changed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)

func initialize_sliders() -> void:
	if FileAccess.file_exists(SaveManager.SAVE_PATH + "settings.sav"):
		SaveManager.load_settings()
		master_slider.value = SaveManager.settings_save.volume.master
		music_slider.value = SaveManager.settings_save.volume.music
		sfx_slider.value = SaveManager.settings_save.volume.sfx
	else:
		master_slider.value = AudioManager.get_bus_volume("Master")
		music_slider.value = AudioManager.get_bus_volume("Music")
		sfx_slider.value = AudioManager.get_bus_volume("SFX")
		AudioManager.set_bus_volume( "Master", master_slider.value )
		AudioManager.set_bus_volume( "Music", music_slider.value )
		AudioManager.set_bus_volume( "SFX", sfx_slider.value )
	

func _on_back_pressed() -> void:
	back_pressed.emit()

func _on_master_volume_changed(value: float) -> void:
	AudioManager.set_bus_volume("Master", value)
	SaveManager.save_settings()

func _on_music_volume_changed(value: float) -> void:
	AudioManager.set_bus_volume("Music", value)
	SaveManager.save_settings()

func _on_sfx_volume_changed(value: float) -> void:
	AudioManager.set_bus_volume("SFX", value)
	SaveManager.save_settings()
