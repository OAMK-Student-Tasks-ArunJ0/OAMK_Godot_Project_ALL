# item_dropper.gd
# drops item at the sign of a signal from the scene
@tool
class_name ItemDropper extends Node

# Preload the item pickup scene.
const PICKUP = preload("res://Interactable/Items/Scenes/item_node.tscn")

@export var item_data : ItemData : set = _set_item_data

@onready var sprite: Sprite2D = $Sprite2D
@onready var item_has_dropped: PersistentDataHandler = $PersistentDataHandler
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Tracks whether the item has already been dropped.
var has_dropped : bool = false

func _ready() -> void:
	# In editor mode, update the texture for preview and exit.
	if Engine.is_editor_hint():
		_update_texture()
		return
	
	# Hide the sprite in game and set up persistent data signal.
	sprite.visible = false
	item_has_dropped.data_loaded.connect(_on_data_loaded)
	_on_data_loaded()

func _on_data_loaded() -> void:
	# Set the dropped state based on persistent data.
	has_dropped = item_has_dropped.value
	pass

func drop_item() -> void:
	# If already dropped, do nothing.
	if has_dropped:
		return
	has_dropped = true
	
	# Instantiate the pickup item and set its data.
	var drop = PICKUP.instantiate() as ItemNode
	drop.item_data = item_data
	add_child(drop)
	# Connect to the pickup signal to update persistent data when picked up.
	drop.item_has_been_picked_up.connect(_on_drop_pickup)
	audio.play()

func _on_drop_pickup() -> void:
	# Mark the item as dropped in persistent data.
	item_has_dropped.set_value()

func _set_item_data(value : ItemData) -> void:
	# Set the item data and update the texture.
	item_data = value
	_update_texture()

func _update_texture() -> void:
	# In editor mode, update the sprite texture for preview.
	if Engine.is_editor_hint():
		if item_data and sprite:
			sprite.texture = item_data.texture
