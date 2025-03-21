# key_door.gd
# A door that requires a key item to open. It uses persistent data to remember its open state.

class_name KeyDoor extends Node2D

var is_open : bool = false

@export var key_item : ItemData  # The item required to unlock the door.

@export var locked_audio : AudioStream
@export var open_audio : AudioStream

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var is_open_data: PersistentDataHandler = $PersistentDataHandler
@onready var interact_area: Area2D = $InteractArea2D

var opening_active : bool = false

func _ready() -> void:
	# Connect signals for player interaction.
	interact_area.area_entered.connect(_on_area_enter)
	interact_area.area_exited.connect(_on_area_exit)
	# Update door state from persistent data.
	is_open_data.data_loaded.connect(set_state)
	set_state()

func open_door() -> void:
	# If no key is set, do nothing.
	if key_item == null or opening_active == true:
		return
	opening_active = true
	# Attempt to use the key from the player's inventory.
	var door_unlocked = PlayerManager.INVENTORY_DATA.use_item(key_item)
	
	if door_unlocked:
		# If successful, display a message, play the open animation and audio, and save state.
		SaveManager.new_hud_message.emit("Door Unlocked!", 1.0)
		animation_player.play("open_door")
		audio.stream = open_audio
		is_open_data.set_value()
	else:
		# Otherwise, inform the player that the door is locked.
		SaveManager.new_hud_message.emit("Door Locked...", 1.0)
		audio.stream = locked_audio
		opening_active = false
	audio.play()
	pass

func close_door() -> void:
	# Play the closing animation.
	animation_player.play("close_door")

func set_state() -> void:
	# Update the door's open state based on persistent data.
	is_open = is_open_data.value
	if is_open:
		animation_player.play("open")
	else:
		animation_player.play("closed")

func _on_area_enter(_a : Area2D) -> void:
	# When the player enters, connect the interact signal.
	PlayerManager.interact_pressed.connect(open_door)

func _on_area_exit(_a : Area2D) -> void:
	# When the player exits, disconnect the interact signal.
	PlayerManager.interact_pressed.disconnect(open_door)
