# enemy_state_death.gd
# This state handles the death of an enemy.
# When triggered (typically when HP is depleted), it plays a death animation,
# disables collisions, drops items based on defined drop data, and then frees the enemy node.

class_name EnemyStateDeath extends EnemyState

const PICKUP = preload("res://Interactable/Items/Scenes/item_node.tscn")

@export var anim_name: String = "death"
@export var knockback_speed: float = 200.0
@export var decelerate_speed: float = 10.0

@export_category("AI")
@export_category("Item Drops")
@export var drops: Array[DropData]

var _damage_position: Vector2
var _direction: Vector2

func init() -> void:
	# Connect to the enemy_dead signal to trigger death.
	enemy.enemy_dead.connect(_on_enemy_death)
	pass

func enter() -> void:
	# Make the enemy invulnerable during death.
	enemy.invulnerable = true
	# Calculate knockback direction based on damage position.
	_direction = enemy.global_position.direction_to(_damage_position)
	enemy.set_direction(_direction)
	enemy.velocity = _direction * -knockback_speed
	enemy.update_animation(anim_name)
	enemy.animation_player.animation_finished.connect(_on_animation_finished)
	disable_hurt_box()
	drop_items()
	pass

func exit() -> void:
	pass

func process(_delta: float) -> EnemyState:
	# Decelerate enemy velocity over time.
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	return null

func _on_enemy_death(hurt_box: HurtBox) -> void:
	_damage_position = hurt_box.global_position
	state_machine.change_state(self)

func _on_animation_finished(_a: String) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.queue_free()

func disable_hurt_box() -> void:
	# Disable the enemy's hurt box so it no longer interacts with damage.
	var hurt_box: HurtBox = enemy.get_node_or_null("HurtBox")
	if hurt_box:
		hurt_box.monitoring = false

func drop_items() -> void:
	# If no drops are defined, do nothing.
	if drops.size() == 0:
		return
	
	# For each drop data entry, determine drop count and instantiate item nodes.
	for i in drops.size():
		if drops[i] == null or drops[i].item == null:
			continue
		var drop_count: int = drops[i].get_drop_count()
		for j in drop_count:
			var drop: ItemNode = PICKUP.instantiate() as ItemNode
			drop.item_data = drops[i].item
			# Use call_deferred to safely add the drop node.
			enemy.get_parent().call_deferred("add_child", drop)
			drop.global_position = enemy.global_position
			# Apply a slight random variation to drop velocity.
			drop.velocity = enemy.velocity.rotated(randf_range(-1.5, 1.5)) * randf_range(0.9, 1.5) * 0.3
	pass
