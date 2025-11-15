@tool
class_name Trigger extends Area3D
@export_tool_button("Rebuild") var rebuild_action = rebuild

@export var references : Node3D
@export var target_name = ""

signal on_rebuild
signal on_trigger
signal on_trigger_plus_x
signal on_trigger_minus_x
signal on_trigger_plus_y
signal on_trigger_minus_y
signal on_trigger_plus_z
signal on_trigger_minus_z


func _ready():
	self.body_exited.connect(
		func(_body):
			trigger()
	)
	
	self.body_exited.connect(
		func(_body):
			var size = $Shape.shape.size
			if Player.body.global_position.x > self.global_position.x + (size.x/2.0):
				on_trigger_plus_x.emit()
	)
	
	self.body_exited.connect(
		func(_body):
			var size = $Shape.shape.size
			if Player.body.global_position.x < self.global_position.x - (size.x/2.0):
				on_trigger_minus_x.emit()
	)
	
	self.body_exited.connect(
		func(_body):
			var size = $Shape.shape.size
			if Player.body.global_position.y > self.global_position.y + (size.y/2.0):
				on_trigger_plus_y.emit()
	)
	
	self.body_exited.connect(
		func(_body):
			var size = $Shape.shape.size
			if Player.body.global_position.y < self.global_position.y - (size.y/2.0):
				on_trigger_minus_y.emit()
	)
	
	self.body_exited.connect(
		func(_body):
			var size = $Shape.shape.size
			if Player.body.global_position.z > self.global_position.z + (size.z/2.0):
				on_trigger_plus_z.emit()
	)
	
	self.body_exited.connect(
		func(_body):
			var size = $Shape.shape.size
			if Player.body.global_position.z < self.global_position.z - (size.z/2.0):
				on_trigger_minus_z.emit()
	)

func rebuild():
	assert(target_name != "", "Must have a target name")
	
	var target = references.get_node_or_null(target_name)
	assert(target, "Must have a valid target")
	
	var target_aabb : AABB = target.get_child(0).get_aabb()
	
	self.global_position = target.global_position
	
	for child in self.get_children():
		child.free()
	
	var collision_shape := CollisionShape3D.new()
	add_child(collision_shape)
	collision_shape.name = "Shape"
	collision_shape.owner = self.owner
	
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = target_aabb.size
	
	collision_layer = 2
	collision_mask = 2
	on_rebuild.emit()
func trigger():
	on_trigger.emit()
