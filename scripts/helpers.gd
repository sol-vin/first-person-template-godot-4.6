@tool
extends Node

# Sets the owner of this node recursively
func set_owner_recursively(node: Node, new_owner: Node):
	# Set the owner of the current node
	node.owner = new_owner
	# Iterate through all children of the current node
	for child in node.get_children():
		# Recursively call the function for each child
		set_owner_recursively(child, new_owner)

# Gets the facing information out of a specific texture. The material must have exactly 2 faces.
func get_facing_info(node : Node, facing_material : Material):
	var facing_mesh : MeshInstance3D
	var surface_id = 0
	var info = {}
	
	for frame_child in node.get_children():
		if frame_child is MeshInstance3D:
			for frame_surface_id in frame_child.mesh.get_surface_count():
				if frame_child.mesh.surface_get_material(frame_surface_id).resource_path == facing_material.resource_path:
					facing_mesh = frame_child
					surface_id = frame_surface_id
					break
		if facing_mesh:
			break
	assert(facing_mesh, "Incoming Frame from trenchbroom did not have a facing material. Cannot determine rotation")
	info["mesh"] = facing_mesh
	info["surface_id"] = surface_id
	
	
	for frame_surface_id in facing_mesh.mesh.get_surface_count():
		var is_frame = facing_mesh.mesh.surface_get_material(frame_surface_id).resource_path == facing_material.resource_path
		var is_trans = facing_mesh.mesh.surface_get_material(frame_surface_id).resource_path == "res://textures/special/trans.tres"
		if !is_frame && !is_trans:
			info["material"] = facing_mesh.get_active_material(frame_surface_id)
			break
	
	var mesh_data := MeshDataTool.new()
	mesh_data.create_from_surface(facing_mesh.mesh, surface_id)
	info["normal"] = mesh_data.get_face_normal(0)
	
	info["rotation_y"] = Vector2(-info["normal"].x, info["normal"].z).angle() + PI/2

	#print(facing_corners)
	var min_x = INF
	var max_x = -INF

	var min_y = INF
	var max_y = -INF


	var min_z = INF
	var max_z = -INF
	
	for vertex in mesh_data.get_vertex_count():
		var v = mesh_data.get_vertex(vertex)
		min_x = min(min_x, v.x)
		max_x = max(max_x, v.x)
		min_y = min(min_y, v.y)
		max_y = max(max_y, v.y)
		min_z = min(min_z, v.z)
		max_z = max(max_z, v.z)

	var center_point = Vector3(min_x, min_y, min_z) + (Vector3(max_x, max_y, max_z) - Vector3(min_x, min_y, min_z))/Vector3(2.0, 2.0, 2.0)
	info["center_point"] = node.global_position + center_point
	
	
	var facing_aabb = facing_mesh.get_aabb()
	var top_aabb = Rect2(facing_aabb.position.x, facing_aabb.position.z, facing_aabb.size.x, facing_aabb.size.y)
	
	var front_1 = Vector2(min_x, min_z)
	var front_2 = Vector2(max_x, max_z)
	var angle : float = (front_1-front_2).angle()
	var hyp = front_1.distance_to(front_2)
	var x_length = abs(front_1.x - front_2.x)
	var adj_length = top_aabb.size.x - x_length
	var z_length = abs(adj_length/sin(angle))
	
	info["facing_aabb"] = facing_aabb
	info["front_1"] = front_1
	info["front_2"] = front_2
	info["angle"] = angle
	info["hyp"] = hyp
	info["x_length"] = x_length
	info["adj_length"] = adj_length
	info["z_length"] = z_length
	return info

# Find all nodes that start with `node_name_prefix`
func find_all_nodes(node_parent : Node3D, node_name_prefix : String):
	var children = []
	for child in node_parent.get_children():
		if child.name.begins_with(node_name_prefix):
			children.push_back(child)
	return children

## Finds the first slot in this mesh with a material
func find_first_material(mesh : Mesh, material : Material) -> int:
	for mesh_surface_id in mesh.get_surface_count():
		if mesh.surface_get_material(mesh_surface_id).resource_path == material.resource_path:
			return mesh_surface_id
	return -1

## Finds all surface indexes for a specific mesh
func find_material_indexes_in_mesh(material : Material, mesh : Mesh):
	var result = []
	for surface_id in mesh.get_surface_count():
		if mesh.surface_get_material(surface_id).resource_path == material.resource_path:
			result.push_back(surface_id)
	return result

## Handy function to turn nodes on
func turn_on(node : Node3D):
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	node.set_physics_process(true)
	node.show()

## Handy function to turn nodes off
func turn_off(node : Node3D):
	node.process_mode = Node.PROCESS_MODE_DISABLED
	node.set_physics_process(false)
	node.hide()

## Runs the rebuild function of all nodes underneath node and including node.
func rebuild(node : Node):
	for child in node.get_children():
		var build_text = ("Building %s" % child.owner.get_path_to(child))
		
		if child is FuncGodotMap:
			print(build_text)
			child.build()
		elif child is RebuildHandler:
			print(build_text)
			child.rebuild()
		elif child is Trigger:
			print(build_text)
			child.rebuild()
