@tool
## Aligns this node with another node
class_name Aligner extends RebuildHandler
@export var target := ""
@export var references : Node

@export var facing_material : Material

func get_reference() -> Node:
	return references.get_node(target)

func rebuild():
	var node = get_reference()

	if facing_material:
		var info = Helpers.get_facing_info(node, facing_material)
		self.look_at_from_position(Vector3.ZERO, info["normal"] * 10)
	
	self.global_position = node.global_position
	super()
