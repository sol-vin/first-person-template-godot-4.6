@tool 

extends StaticBody3D
class_name Chair

@export var facing_normal : Vector3
@export var facing_material = preload("res://textures/special/frame.tres")

func _ready() -> void:
	var click_action = get_click_action()
	if !Engine.is_editor_hint() and click_action:
		click_action.on_left_click_released.connect(
			func(_item): 
				var camera = get_camera()
				Player.sit_toggle(camera.global_position, camera.global_rotation)
		)

func get_camera():
	for child in get_children():
		if child is Marker3D:
			return child
	return null
	
func get_click_action():
	for child in get_children():
		if child is ClickAction:
			return child
	return null

func make_nodes():
	var facing_info = Helpers.get_facing_info(self, facing_material)
	# Make a camera
	#   - Aim it at the direction of the facing mesh 
	#   - Disable camera
	if get_camera():
		get_camera().free()
	
	var camera = Marker3D.new()
	add_child(camera)
	camera.owner = self.owner
	camera.global_position = facing_info["center_point"]
	facing_normal = facing_info["normal"]
	camera.global_transform = camera.global_transform.looking_at(camera.global_position + (facing_normal * 100))
	
	# Make a ClickAction
	#   - Tie sit() to on_left_click()
	var click_action = ClickAction.new()
	add_child(click_action)
	click_action.owner = self.owner
	click_action.name = "ClickAction"
	# click_action.on_left_click.connect(toggle)
	
	
@export var no_vertex_coloring = false
@export_flags_2d_render var layers = 5

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
	make_nodes()
	
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
