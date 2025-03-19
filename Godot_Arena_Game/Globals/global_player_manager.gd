# global_player_manager.gd
# This script manages the player character including instantiation, positioning,
# and updating player-related attributes such as health, damage, and accessories.
# It also provides a function to play audio associated with the player.

extends Node

# Preload the player scene and inventory data.
const PLAYER = preload("res://Characters/Player/Scenes/player.tscn")
const INVENTORY_DATA : InventoryData = preload("res://GUI/Inventory/Resources/player_inventory.tres")

# Signal emitted when the interact action is pressed.
signal interact_pressed

# Reference to the player instance.
var player : Player
# Flag to indicate if the player has been spawned.
var player_spawned : bool = false

func _ready() -> void:
	# Add the player instance to the scene.
	add_player_instance()
	# Delay to ensure player initialization.
	await get_tree().create_timer(0.2).timeout
	player_spawned = true

# Instantiate the player and add it as a child.
func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child(player)

# Set the player's health values and update the health bar/UI.
func set_health(hp: int, max_hp: int) -> void:
	player.max_hp = max_hp
	player.hp = hp
	player.update_hp(0)

# Set player accessories such as weapons, dash ability, and sword range.
func set_player_accessories(ranged_weapon : String, dash_unlocked : bool, sword_range : float) -> void:
	player.ranged_weapon = ranged_weapon
	player.dash_unlocked = dash_unlocked
	player.sword_range = sword_range

# Set the player's damage values for sword and ranged attacks.
func set_damage(sword_damage: int, ranged_damage: int) -> void:
	player.sword_damage = sword_damage
	player.ranged_damage = ranged_damage
	# Initialize the damage for the attack hitbox.
	player.attack_hurt_box.init_damage(sword_damage)

# Update the player's global position.
func set_player_position(newpos: Vector2) -> void:
	player.global_position = newpos

# Reparent the player to a new parent node.
func set_as_parent(p: Node2D) -> void:
	if player.get_parent():
		player.get_parent().remove_child(player)
	p.add_child(player)

# Remove the player from its current parent node.
func unparent_player(p: Node2D) -> void:
	p.remove_child(player)

# Play an audio stream on the player's audio node.
func play_audio(audio: AudioStream) -> void:
	player.audio.stream = audio
	player.audio.play()
