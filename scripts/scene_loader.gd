class_name SceneLoader extends Node

## This is emitted when the scene is finished loading.
## Use `ResourceLoader.load_threaded_get(path)` to get the scene.
signal scene_loaded(scene : Node)

## The path to the scene that's actually being loaded
@export var instance_placeholder: Node

## Load the scene at the given path.
## When this is finished loading, the "scene_loaded" signal will be emitted.
func load():
	ResourceLoader.load_threaded_request(instance_placeholder.get_instance_path())


func _process(delta: float):
	if not instance_placeholder:
		return

	var status = ResourceLoader.load_threaded_get_status(instance_placeholder.get_instance_path())

	if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		scene_loaded.emit(ResourceLoader.load_threaded_get(instance_placeholder.get_instance_path()).instantiate())
			
