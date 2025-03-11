# navigator.gd
# This node calculates a preferred movement direction for an enemy.
# It uses multiple RayCast2D nodes to detect obstacles and combines
# their results with an attraction toward the player to determine a “best path.”

class_name Navigator extends Node2D

@onready var timer: Timer = $Timer

# Predefined normalized direction vectors (8 directions).
var vectors: Array[Vector2] = [
	Vector2(0, -1),     # up
	Vector2(1, -1),     # up-right
	Vector2(1, 0),      # right
	Vector2(1, 1),      # down-right
	Vector2(0, 1),      # down
	Vector2(-1, 1),     # down-left
	Vector2(-1, 0),     # left
	Vector2(-1, -1)     # up-left
]

# Attraction values represent desire to move toward a direction (toward the player).
var attractions: Array[float]
# Obstacle influence values for each direction.
var objects: Array[float] = [0, 0, 0, 0, 0, 0, 0, 0]
# Combined scores for each direction.
var possible_directions: Array[float] = [0, 0, 0, 0, 0, 0, 0, 0]
var rays: Array[RayCast2D]  # RayCast nodes used to detect obstacles.

# Final chosen movement direction.
var move_direction: Vector2 = Vector2.ZERO
var best_path: Vector2 = Vector2.ZERO

var current_raycast_length: float

func _ready() -> void:
	# Gather all child RayCast2D nodes.
	for r in get_children():
		if r is RayCast2D:
			rays.append(r)
		
	# Normalize the direction vectors.
	for v in vectors.size():
		vectors[v] = vectors[v].normalized()
	
	# Calculate the initial best path.
	set_best_path()
	
	# Connect the timer to regularly update the best path.
	timer.timeout.connect(set_best_path)
	pass

func _process(delta: float) -> void:
	# Gradually update the move_direction toward the best_path.
	move_direction = lerp(move_direction, best_path, 10 * delta)
	pass

func set_raycast_length(length: float) -> void:
	# Adjust the length of all raycasts.
	for r in get_children():
		if r is RayCast2D:
			r.target_position.y = length
	current_raycast_length = length

func set_best_path() -> void:
	# Calculate the direction toward the player.
	var player_direction: Vector2 = global_position.direction_to(PlayerManager.player.global_position)
	
	# Reset obstacle values.
	for i in 8:
		objects[i] = 0
		possible_directions[i] = 0
	
	# Use raycasts to determine obstacles.
	for i in 8:
		if rays[i].is_colliding():
			objects[i] += 4
			objects[get_next_i(i)] += 1
			objects[get_previous_i(i)] += 1
			
	# If no obstacles are detected, choose the direction toward the player.
	if objects.max() == 0:
		best_path = player_direction
		return
	
	# Calculate attraction values based on alignment with player direction.
	attractions.clear()
	for a in vectors:
		attractions.append(a.dot(player_direction))
	
	# Combine attraction and obstacle influence.
	for p in 8:
		possible_directions[p] = attractions[p] - objects[p]
	
	# Choose the direction with the highest combined score.
	best_path = vectors[possible_directions.find(possible_directions.max())]
	pass

func get_next_i(i: int) -> int:
	var n_i: int = i + 1
	if n_i >= 8:
		return 0
	else:
		return n_i

func get_previous_i(i: int) -> int:
	var n_i: int = i - 1
	if n_i < 0:
		return 7
	else:
		return n_i
