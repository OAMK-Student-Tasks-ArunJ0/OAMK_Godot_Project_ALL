extends CanvasLayer

var health_bars : Array[ HealthBar ] = []

@onready var message_label: Label = $Control/Message_Label
@onready var hud_animation_player: AnimationPlayer = $Control/AnimationPlayer

func _ready() -> void:
	SaveManager.new_hud_message.connect( _new_hud_message )
	for child in $Control/HFlowContainer.get_children():
		if child is HealthBar:
			health_bars.append( child )
			child.visible = false
	pass

func update_hp( _hp : int , _max_hp : int ) -> void:
	update_max_hp( _max_hp )
	for i in _max_hp:
		update_healthbar( i, _hp )
		pass
	pass

func update_healthbar( _index : int, _hp : int ) -> void:
	var _value : int = clampi( _hp - _index * 2, 0, 2 )
	health_bars[ _index ].value = _value
	pass

func update_max_hp( _max_hp : int ) -> void:
	var _health_bar_count : int = roundi( _max_hp * 0.5 )
	for i in health_bars.size():
		if i < _health_bar_count:
			health_bars[i].visible = true
		else:
			health_bars[i].visible = false
	pass

func _new_hud_message( message_text : String ) -> void:
	message_label.text = message_text
	hud_animation_player.play("message_animation")
	pass
