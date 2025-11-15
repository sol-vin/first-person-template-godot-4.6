class_name ReferenceBrush extends Node3D

@export var properties : Dictionary

func _func_godot_apply_properties(props: Dictionary) -> void:
	properties = props 
	if props.has("name"):
		self.name = props["name"]

func on_map_build():
	for world_spawn_child in self.get_children():
		if world_spawn_child is MeshInstance3D:
			var polygon_mesh : PolygonMesh = PolygonMesh.new()
			polygon_mesh.mesh = world_spawn_child.mesh.duplicate()
			polygon_mesh.extra_cull_margin = 1.0
			self.add_child(polygon_mesh)
			polygon_mesh.owner = self.owner
			polygon_mesh.rebuild_face_data()
			polygon_mesh.name = "polygon"
			polygon_mesh.layers = world_spawn_child.layers
			world_spawn_child.free()
