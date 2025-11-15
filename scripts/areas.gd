## Holds all the levels in the world and handles loading and unloading leaf levels.
extends Node3D

## Holds the current loading status check callbacks to be run every `_process`
var loading : Dictionary[String, Callable] = {}

func is_area_loading(name : String) -> bool:
	return loading.has(name)

func is_area_loaded(name : String) -> bool:
	return self.get_node_or_null(name) != null

## Loads the whole level and areas without threads
func force_load(name : String, packed_scene_path : String, include_leaves = true):
	if !is_area_loading(name) and !is_area_loaded(name):
		# Unthreaded load the level
		var level : Level = load(packed_scene_path).instantiate()
		level.name = name
		level.owner = self.owner
		self.add_child(level)
		level.load()
		
		if include_leaves:
			for leaf in level.leaves.keys():
				# Lazy load the leaves via thread
				self.load(leaf, level.leaves[leaf])

## Loads the next area in by lazy loading all of it's leaves. It then prunes old leaves that aren't needed
func load_next_area(name : String):
	# This should already be loaded
	if is_area_loaded(name):
		# Go through all the leaves and start loading them
		var area = self.get_node(name)
		for leaf_name in area.leaves.keys():
			if !is_area_loaded(leaf_name):
				print("Loading %s" % leaf_name)
				self.load(leaf_name, area.leaves[leaf_name])
		
		# Find all the leaves that can be removed and remove them
		var areas : Array[String] = [name]
		areas.append_array(area.leaves.keys())
		for child in self.get_children():
			if !areas.has(child.name):
				child.queue_free()
	else:
		assert(false, "%s attempted load_next_area but wasn't loaded" % name)

## Loads the level without loading it's leaves
func load(name : String, packed_scene_path : String):
	if !is_area_loading(name) and !is_area_loaded(name):
		# Start the lazy loading process
		ResourceLoader.load_threaded_request(packed_scene_path, "", true)
		# Status check callback
		loading[name] = func ():
			# Check status of load
			var status = ResourceLoader.load_threaded_get_status(packed_scene_path)
			if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				var level = ResourceLoader.load_threaded_get(packed_scene_path).instantiate()
				level.name = name
				self.add_child(level)
				level.owner = self.owner
				# Remove from the callbacks
				loading.erase(name)

# Unloads a specific level
func unload(name : String):
	var area = self.get_node(name)
	if area:
		area.unload()
		area.queue_free()

func _process(delta: float) -> void:
	# if !loading.is_empty():
	# 	print(loading)
	# Run the loading callbacks
	for name in loading.keys():
		loading[name].call()
		
