@tool
class_name Map extends FuncGodotMap

signal on_rebuild_complete

func _ready():
	build_complete.connect(on_build_complete)
	#build_map()

func on_build_complete():
	for child in get_children():
		# Calculate polygons for WorldSpawns
		
		if child.has_method("on_map_build"):
			child.on_map_build()
		elif child.has_method("rebuild"):
			child.rebuild()
	on_rebuild_complete.emit()
