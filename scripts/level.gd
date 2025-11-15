@tool

extends Node3D
class_name Level 

@export_tool_button("Rebuild") var rebuild_action = rebuild
@export var leaves : Dictionary[String, String] = {}

signal on_load
signal on_unload
signal on_rebuild

#func _ready():
	#self.load()

func rebuild():
	Helpers.rebuild(self)
	on_rebuild.emit()
	
func load():
	on_load.emit()
	
func unload():
	on_unload.emit()
