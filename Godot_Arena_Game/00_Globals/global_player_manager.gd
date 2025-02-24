# global_player_manager.gd
extends Node

const PLAYER = preload("res://Characters/Player/Scenes/player.tscn")
const INVENTORY_DATA : InventoryData = preload("res://GUI/Inventory/Resources/player_inventory.tres")

signal interact_pressed

var player : Player
var player_spawned : bool = false

func _ready() -> void:
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true

func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child(player)

func set_health(hp: int, max_hp: int) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp(0)

func set_player_accessories( ranged_weapon : String ) -> void:
	player.ranged_weapon = ranged_weapon

func set_damage(sword_damage: int, ranged_damage: int) -> void:
	player.sword_damage = sword_damage
	player.ranged_damage = ranged_damage
	player.attack_hurt_box.init_damage(sword_damage)

func set_player_position(newpos: Vector2) -> void:
	player.global_position = newpos

func set_as_parent(p: Node2D) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	p.add_child(player)

func unparent_player(p: Node2D) -> void:
	p.remove_child(player)

func play_audio(audio: AudioStream) -> void:
	player.audio.stream = audio
	player.audio.play()
