# item_node.gd
# This node represents an item placed in the game world.
# It handles collisions with the player to pick up the item,
# plays a pickup sound, and then removes itself from the scene.

@tool
class_name ItemNode extends CharacterBody2D

signal item_has_been_picked_up

# Holds the item data; setting it updates the item's texture.
@export var item_data : ItemData : set = _set_item_data

@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	# Update the texture based on the item data.
	_update_texture()
	# If in editor mode, do not proceed with runtime logic.
	if Engine.is_editor_hint():
		return
	# Connect collision signal to detect when the player picks up the item.
	area_2d.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# Move the item and handle collisions to prevent stacking or embedding in walls.
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
	# Apply friction to slow down the item.
	velocity -= velocity * delta * 4

func _on_body_entered(b) -> void:
	# When a body enters, check if it is the player.
	if b is Player:
		if item_data:
			# Try to add the item to the player's inventory.
			if PlayerManager.INVENTORY_DATA.add_item(item_data) == true:
				item_picked_up()
	pass

func item_picked_up() -> void:
	# Disconnect to avoid duplicate pickup events.
	area_2d.body_entered.disconnect(_on_body_entered)
	# Play the pickup sound.
	audio_stream_player_2d.play()
	# Hide the item.
	visible = false
	# Emit the pickup signal.
	item_has_been_picked_up.emit()
	# Wait for the audio to finish before freeing the node.
	await audio_stream_player_2d.finished
	queue_free()
	pass

func _set_item_data(value : ItemData) -> void:
	# Set the item data and update the texture.
	item_data = value
	_update_texture()
	pass

func _update_texture() -> void:
	# Update the sprite texture based on the current item data.
	if item_data and sprite_2d:
		sprite_2d.texture = item_data.texture
	pass
