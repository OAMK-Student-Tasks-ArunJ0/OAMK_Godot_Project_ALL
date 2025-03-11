# scene_transition.gd
# This script handles fade in/out transitions between scenes using animations.

extends CanvasLayer

@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer

func fade_out() -> bool:
	# Play the fade-out animation and wait for it to finish.
	animation_player.play("fade_out")
	await animation_player.animation_finished
	return true

func fade_in() -> bool:
	# Play the fade-in animation and wait for it to finish.
	animation_player.play("fade_in")
	await animation_player.animation_finished
	return true
