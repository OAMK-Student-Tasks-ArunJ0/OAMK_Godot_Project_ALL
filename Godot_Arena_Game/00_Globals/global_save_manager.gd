# global_save_manager.gd
extends Node

const SAVE_PATH = "user://"


signal game_loaded
signal game_saved

signal new_hud_message

var current_save : Dictionary

var new_game_save : Dictionary= {
	scene_path = "res://Levels/Maps/Area01/01_Dungeon.tscn",
	player = {
		hp = 12,
		max_hp = 12,
		pos_x = 0,
		pos_y = 0,
		sword_damage = 2,
		ranged_damage = 1,
		ranged_weapon = ""
	},
	items = [],
	persistence = [],
	quests = [],
}


var settings_save : Dictionary = {
	volume = {
		master = 1,
		sfx = 1,
		music = 1
	}
}

func _ready() -> void:
	# if no previous saves applies the save to current save
	if current_save == null:
		current_save = new_game_save
	
	if FileAccess.file_exists(SaveManager.SAVE_PATH + "save.sav"):
		var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.READ )
		var json := JSON.new()
		json.parse( file.get_line() )
		var save_dict : Dictionary = json.get_data() as Dictionary
		current_save = save_dict
	pass


func new_game() -> void:
	current_save = new_game_save
	await get_tree().create_timer(0.5).timeout
	var p : Player = PlayerManager.player
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y
	
	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.WRITE )
	var save_json = JSON.stringify( current_save )
	file.store_line( save_json )
	
	new_hud_message.emit( "New Game" )
	game_saved.emit()
	pass


func save_game() -> void:
	update_player_data()
	update_scene_path()
	update_item_data()
	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.WRITE )
	var save_json = JSON.stringify( current_save )
	file.store_line( save_json )
	
	new_hud_message.emit( "Game Saved" )
	game_saved.emit()
	
	pass


func load_game() -> void:
	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.READ )
	var json := JSON.new()
	json.parse( file.get_line() )
	var save_dict : Dictionary = json.get_data() as Dictionary
	current_save = save_dict
	
	LevelManager.load_new_level( current_save.scene_path, "", Vector2.ZERO )
	
	await LevelManager.level_load_started
	
	PlayerManager.set_player_position( Vector2( current_save.player.pos_x, current_save.player.pos_y ) )
	PlayerManager.set_health( current_save.player.hp, current_save.player.max_hp )
	PlayerManager.set_player_accessories( current_save.player.ranged_weapon )
	PlayerManager.set_damage( current_save.player.sword_damage, current_save.player.ranged_damage )
	PlayerManager.INVENTORY_DATA.parse_save_data( current_save.items )
	
	
	await LevelManager.level_loaded
	
	new_hud_message.emit( "Game Loaded" )
	game_loaded.emit()
	
	pass

func save_settings() -> void:
	settings_save.volume.master = AudioManager.get_bus_volume("Master")
	settings_save.volume.music = AudioManager.get_bus_volume("Music")
	settings_save.volume.sfx = AudioManager.get_bus_volume("SFX")
	
	var file := FileAccess.open( SAVE_PATH + "settings.sav", FileAccess.WRITE )
	var save_json = JSON.stringify( settings_save )
	file.store_line( save_json )
	
	# new_hud_message.emit( "Settings Saved" )

func load_settings() -> void:
	var file := FileAccess.open( SAVE_PATH + "settings.sav", FileAccess.READ )
	var json := JSON.new()
	json.parse( file.get_line() )
	var save_dict : Dictionary = json.get_data() as Dictionary
	settings_save = save_dict
	
	AudioManager.set_bus_volume( "Master", settings_save.volume.master )
	AudioManager.set_bus_volume( "Music", settings_save.volume.music )
	AudioManager.set_bus_volume( "SFX", settings_save.volume.sfx )
	
	# new_hud_message.emit( "Settings Loaded" )

func update_player_data() -> void:
	var p : Player = PlayerManager.player
	current_save.player.hp = p.hp
	current_save.player.max_hp = p.max_hp
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y
	current_save.player.sword_damage = p.sword_damage
	current_save.player.ranged_damage = p.ranged_damage
	current_save.player.ranged_weapon = p.ranged_weapon
	


func update_scene_path() -> void:
	var p : String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
	current_save.scene_path = p


func update_item_data() -> void:
	current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()


func add_persistent_value( value : String ) -> void:
	if check_persistent_value( value ) == false:
		current_save.persistence.append( value )
	pass


func check_persistent_value( value : String ) -> bool:
	var p = current_save.persistence as Array
	return p.has( value )
