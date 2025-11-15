@tool
extends Node

func set_owner_recursively(node: Node, new_owner: Node):
	# Set the owner of the current node
	node.owner = new_owner
	# Iterate through all children of the current node
	for child in node.get_children():
		# Recursively call the function for each child
		set_owner_recursively(child, new_owner)

static var facing_material = preload("res://textures/special/frame.tres")
func get_facing_info(node : Node):
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

func find_all_nodes(node_parent : Node3D, node_name_prefix : String):
	var children = []
	for child in node_parent.get_children():
		if child.name.begins_with(node_name_prefix):
			children.push_back(child)
	return children


func find_first_material(mesh : Mesh, material : Material) -> int:
	for mesh_surface_id in mesh.get_surface_count():
		if mesh.surface_get_material(mesh_surface_id).resource_path == material.resource_path:
			return mesh_surface_id
	return -1

func find_material_indexes_in_mesh(material : Material, mesh : Mesh):
	var result = []
	for surface_id in mesh.get_surface_count():
		if mesh.surface_get_material(surface_id).resource_path == material.resource_path:
			result.push_back(surface_id)
	return result

func turn_on(node : Node3D):
	node.process_mode = Node.PROCESS_MODE_ALWAYS
	node.set_physics_process(true)
	node.show()
	
func turn_off(node : Node3D):
	node.process_mode = Node.PROCESS_MODE_DISABLED
	node.set_physics_process(false)
	node.hide()

func combine_mesh_instances(instances: Array) -> ArrayMesh:
	var st_map: Dictionary = {}  # material -> SurfaceTool
	var final_mesh := ArrayMesh.new()

	for instance in instances:
		if instance == null:
			continue
		elif !instance is MeshInstance3D:
			continue

		var mesh = instance.mesh
		if mesh == null:
			continue

		for surface_index in mesh.get_surface_count():
			var material = mesh.surface_get_material(surface_index)
			var st: SurfaceTool

			if st_map.has(material):
				st = st_map[material]
			else:
				st = SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				st_map[material] = st

			st.append_from(mesh, surface_index, instance.global_transform)

	# Commit each SurfaceTool to the final mesh
	for material in st_map.keys():
		var st = st_map[material]
		final_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, st.commit_to_arrays())
		final_mesh.surface_set_material(final_mesh.get_surface_count() - 1, material)

	return final_mesh

func get_uv_rotation(mesh : Mesh, material : Material) -> float:
	if not mesh:
		assert(false, "Input mesh is null.")

	if mesh.get_surface_count() == 0:
		assert(false, "Mesh has no surfaces.")

	if not material:
		assert(false, "Input material is null.")
	
	var material_idx = find_first_material(mesh, material)


	# Get all the data arrays for the first surface
	var arrays : Array = mesh.surface_get_arrays(material_idx)
	if arrays.is_empty():
		assert(false, "Mesh surface arrays are empty.")

	# Extract the required data
	# We assume the data exists based on the problem description
	var vertices : PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uvs : PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	var indices : PackedInt32Array = arrays[Mesh.ARRAY_INDEX]

	# We need at least one triangle (3 vertices, 3 uvs, 3 indices)
	if vertices.size() < 3 or uvs.size() < 3 or indices.size() < 3:
		assert(false, "Mesh data is incomplete to form a triangle.")

	# --- 1. Get Vertices/UVs for the First Triangle ---
	var idx0 : int = indices[0]
	var idx1 : int = indices[1]
	var idx2 : int = indices[2]

	# Safety check for indices
	var max_idx : int = max(idx0, idx1, idx2)
	if max_idx >= vertices.size() or max_idx >= uvs.size():
		assert(false, "Mesh indices are out of bounds for vertex/UV arrays.")

	var v0 : Vector3 = vertices[idx0]
	var v1 : Vector3 = vertices[idx1]
	var v2 : Vector3 = vertices[idx2]

	var uv0 : Vector2 = uvs[idx0]
	var uv1 : Vector2 = uvs[idx1]
	var uv2 : Vector2 = uvs[idx2]

	# --- 2. Find the Right-Angled Corner using UVs ---
	# UVs are 2D, so finding the right angle is easy with dot product.
	var e_uv_01 : Vector2 = uv1 - uv0
	var e_uv_02 : Vector2 = uv2 - uv0
	var e_uv_12 : Vector2 = uv2 - uv1


	var dot_0 : float = abs(e_uv_01.dot(e_uv_02)) # Angle at uv0
	var dot_1 : float = abs(e_uv_01.dot(e_uv_12)) # Angle at uv1
	# dot_2 uses (v0-v2) and (v1-v2), so (-e_uv_02) and (-e_uv_12)
	var dot_2 : float = abs(e_uv_02.dot(e_uv_12)) # Angle at uv2
	
	var v_edge_a_3d : Vector3
	var v_edge_b_3d : Vector3
	var uv_edge_a_2d : Vector2
	var uv_edge_b_2d : Vector2

	if is_zero_approx(dot_0): # Right angle at vertex 0
		v_edge_a_3d = v1 - v0
		v_edge_b_3d = v2 - v0
		uv_edge_a_2d = e_uv_01
		uv_edge_b_2d = e_uv_02
	elif is_zero_approx(dot_1): # Right angle at vertex 1
		v_edge_a_3d = v0 - v1
		v_edge_b_3d = v2 - v1
		uv_edge_a_2d = -e_uv_01
		uv_edge_b_2d = e_uv_12
	elif is_zero_approx(dot_2): # Right angle at vertex 2
		v_edge_a_3d = v0 - v2
		v_edge_b_3d = v1 - v2
		uv_edge_a_2d = -e_uv_02
		uv_edge_b_2d = -e_uv_12
	else:
		assert(false, "Could not find right angle in UVs. Is mesh a right triangle?")
	
	var len_v_a_sq : float = v_edge_a_3d.length_squared()
	var len_v_b_sq : float = v_edge_b_3d.length_squared()
	var len_uv_a_sq : float = uv_edge_a_2d.length_squared()
	var len_uv_b_sq : float = uv_edge_b_2d.length_squared()

	# Avoid division by zero if we have a degenerate edge
	if is_zero_approx(len_v_b_sq) or is_zero_approx(len_uv_b_sq):
		if is_zero_approx(len_v_a_sq) or is_zero_approx(len_uv_a_sq):
			assert(false, "Degenerate triangle in mesh.")
		# Use b/a ratio instead
		var ratio_v_ba : float = len_v_b_sq / len_v_a_sq
		var ratio_uv_ba : float = len_uv_b_sq / len_uv_a_sq
		var ratio_uv_ab : float = len_uv_a_sq / len_uv_b_sq # Flipped ratio
		
		# We use v_edge_a_3d as our "X-axis" (angle 0)
		# Check if v_a corresponds to uv_a
		if is_zero_approx(abs(ratio_v_ba - ratio_uv_ba)):
			return uv_edge_a_2d.angle()
		# Check if v_a corresponds to uv_b
		elif is_zero_approx(abs(ratio_v_ba - ratio_uv_ab)):
			return uv_edge_b_2d.angle()
		else:
			assert(false, "Mesh/UV shape mismatch (ratio check failed).")
	else:
		# Use a/b ratio
		var ratio_v_ab : float = len_v_a_sq / len_v_b_sq
		var ratio_uv_ab : float = len_uv_a_sq / len_uv_b_sq
		var ratio_uv_ba : float = len_uv_b_sq / len_uv_a_sq # Flipped ratio
		
		# We use v_edge_a_3d as our "X-axis" (angle 0)
		# Check if v_a corresponds to uv_a
		if is_zero_approx(abs(ratio_v_ab - ratio_uv_ab)):
			return uv_edge_a_2d.angle()
		# Check if v_a corresponds to uv_b
		elif is_zero_approx(abs(ratio_v_ab - ratio_uv_ba)):
			return uv_edge_b_2d.angle()
		else:
			assert(false, "Mesh/UV shape mismatch (ratio check failed).")
	return 0.0

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
