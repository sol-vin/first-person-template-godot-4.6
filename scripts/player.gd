class_name PlayerController extends Node3D

signal on_teleport()

var body : EntityBodyComponent
var view : EntityViewComponent
var camera : PlayerCameraComponent


func _ready() -> void:
	body = $"Entity Body Component"
	view = $"Entity View Component"
	camera = $"Player Camera Component"


func get_interact_collider():
	var current_camera = get_viewport().get_camera_3d()
	var params = PhysicsRayQueryParameters3D.new()
	params.hit_back_faces = false
	params.collision_mask = 4
	var midpoint = get_viewport().size/2.0
	
	params.from = current_camera.project_ray_origin(midpoint) 
	params.to = current_camera.project_position(midpoint, 1.85)
	
	var worldspace = get_world_3d().direct_space_state
	var result = worldspace.intersect_ray(params)
	#if result.has("collider"):
		##$DebugLabel.text = result.collider.name
	return result

func _process(delta: float) -> void:
	if !$"Player Input Component".disable_input:
		var result = get_interact_collider()
		if result.has("collider"):
			var found_click = false
			for child in result.collider.get_children():
					if child is ClickAction:
						found_click = true
						Player.get_node("Player Entity Monitor/Crosshair").fade_in()
			if !found_click:
				Player.get_node("Player Entity Monitor/Crosshair").fade_out()
		else:
			Player.get_node("Player Entity Monitor/Crosshair").fade_out()
		if Input.is_action_just_pressed("interact"):
			if result.has("collider"):
				for child in result.collider.get_children():
					if child is ClickAction:
						child.left_click(result.collider)
		if Input.is_action_just_pressed("interact2"):
			if result.has("collider"):
				for child in result.collider.get_children():
					if child is ClickAction:
						child.right_click(result.collider)


var teleport = false
var teleport_from : Node3D
var teleport_to : Node3D
var teleport_y_rotation : float

func teleport_in_relation_to(begin : Node3D, end : Node3D, y_rotation = 0.0):
	# set_physics_process(false)
	var player_offset = body.global_position - begin.global_position
	player_offset = player_offset.rotated(Vector3.UP, y_rotation)
	
	# Custom y_rotation impulse
	view.impulse_y_rotation = y_rotation
	
	body.velocity = body.velocity.rotated(Vector3.UP, y_rotation)
	body.global_position = end.global_position + player_offset
	view.global_position = end.global_position + player_offset

	if sitting:
		var last_position_offset = last_position - begin.global_position
		last_position_offset = last_position_offset.rotated(Vector3.UP, y_rotation)
		last_position = end.global_position + last_position_offset
	
	on_teleport.emit()
	# set_physics_process(true)

func queue_teleport_in_relation_to(begin : Node3D, end : Node3D, y_rotation = 0.0):
	teleport = true
	teleport_from = begin
	teleport_to = end
	teleport_y_rotation = y_rotation

func _physics_process(delta: float) -> void:
	if teleport:
		teleport_in_relation_to(teleport_from, teleport_to, teleport_y_rotation)
		teleport = false



func disable_input():
	self.body.collision_layer = 0
	self.body.collision_mask = 0
	
	Helpers.turn_off(self.body)
	
	# set_process_input(false)
	$"Player Input Component".disable_input = true
	$"Player Entity Monitor/Crosshair".fade_out()
	
func enable_input():
	Helpers.turn_on(self.body)
	self.body.collision_layer = 2
	self.body.collision_mask = 1
	# set_process_input(true)
	$"Player Input Component".disable_input = false

var sitting = false
var last_position = Vector3.ZERO
var last_rotation = Vector3.ZERO


func sit(camera_position, camera_rotation):
	if sitting:
		return
	last_position = body.global_position
	last_rotation = Vector3(self.view.pitch_node.rotation.x, self.view.yaw_node.rotation.y,  0)
	sitting = true
	disable_input()
	var offset = camera.camera.global_position - self.camera.global_position
	self.body.global_position = camera_position + offset
	self.view.pitch_node.rotation.x = camera_rotation.x
	self.view.yaw_node.rotation.y = camera_rotation.y

	#self.view.global_position = camera_position + offset
	
	
	#self.camera.camera.look_at(camera_position + (camera_normal * 100))
	get_tree().create_timer(1.0).timeout.connect(
		func():
			var sitting_listener = SittingListener.new()
			add_child(sitting_listener)
	)

func stand():
	if not sitting:
		return
	body.global_position = last_position
	#self.camera.camera.global_rotation = last_rotation
	self.view.pitch_node.rotation.x = last_rotation.x
	self.view.yaw_node.rotation.y = last_rotation.y
	sitting = false
	enable_input()

func sit_toggle(camera_position, camera_rotation):
	print("TOGGLED")
	if sitting:
		stand()
	else:
		sit(camera_position, camera_rotation)
