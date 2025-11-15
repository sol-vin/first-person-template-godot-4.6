@tool
## Aligns this node with another node
class_name Aligner extends RebuildHandler
@export var target := ""
@export var references : Node

func get_reference() -> Node:
	return references.get_node(target)

func rebuild():
	var node = get_reference()
	self.global_position = node.global_position
	
	super()
