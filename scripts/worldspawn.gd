class_name WorldSpawn extends StaticBody3D

@export var no_vertex_coloring = false
@export_flags_2d_render var layers = 1

func _func_godot_apply_properties(props: Dictionary) -> void:
	if props.has("name"):
		self.name = props["name"]
	if props.has("no_vertex_coloring"):
		self.no_vertex_coloring = props["no_vertex_coloring"] == "1"
	if props.has("layers"):
		self.layers = props["layers"]
	if props.has("collision_layers"):
		self.collision_layer = props["collision_layers"]
	if props.has("collision_mask"):
		self.collision_mask = props["collision_mask"]
		
func on_map_build():
	for child in self.get_children():
		if child is MeshInstance3D:
			child.layers = layers
	if self.no_vertex_coloring:
		return
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
