@tool

## Handles Rebuilding
class_name RebuildHandler extends Node3D
@export_tool_button("Rebuild") var rebuild_action = rebuild

signal on_rebuild()

func rebuild():
	Helpers.rebuild(self)
	on_rebuild.emit()
	
