@tool
class_name TeleportTrigger extends Trigger

@export var dest_references :Node3D
@export var dest_target_name = ""
@export var player_rotation = 0.0

signal on_teleport

#func _ready() -> void:
	#collision_layer = 2
	#collision_mask = 2

func rebuild():
	assert(dest_target_name != "Must have an end name")
	
	super()

func teleport():
	var begin = references.get_node(target_name)
	var end = dest_references.get_node(dest_target_name)
	Player.queue_teleport_in_relation_to(begin, end, player_rotation)
	on_teleport.emit()
