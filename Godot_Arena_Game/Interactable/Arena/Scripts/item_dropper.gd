@tool
class_name ItemDropper extends Node


const PICKUP = preload("res://Interactable/Items/Scenes/item_node.tscn")

@export var item_data : ItemData : set = _set_item_data

@onready var sprite: Sprite2D = $Sprite2D
@onready var item_has_dropped: PersistentDataHandler = $PersistentDataHandler
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var has_dropped : bool = false

func _ready() -> void:
	if Engine.is_editor_hint() == true:
		_update_texture()
		return
	
	sprite.visible = false
	item_has_dropped.data_loaded.connect( _on_data_loaded )
	_on_data_loaded()




func _on_data_loaded() -> void:
	has_dropped = item_has_dropped.value
	pass


func drop_item() -> void:
	if has_dropped == true:
		return
	has_dropped = true
	
	var drop = PICKUP.instantiate() as ItemNode
	drop.item_data = item_data
	add_child( drop )
	drop.item_has_been_picked_up.connect( _on_drop_pickup )
	audio.play()

func _on_drop_pickup() -> void:
	item_has_dropped.set_value()

func _set_item_data( value : ItemData ) -> void:
	item_data = value
	_update_texture()


func _update_texture() -> void:
	if Engine.is_editor_hint() == true:
		if item_data and sprite:
			sprite.texture = item_data.texture
