@tool
class_name MaterialsList extends Resource

@export_tool_button("Rebuild", "Color") var rebuild_action = rebuild

@export var all : Dictionary[String, Material] = {}

func rebuild():
	all = {}
	var paths = ["res://textures/", "res://textures/full/"]
	for path in paths:
		var dir := DirAccess.open(path)

		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if dir.current_is_dir():
					pass
				else:
					# This is a file
					print("Found file: " + file_name)
					if !file_name.ends_with(".tres"):
						pass
					else:
						var resource = load("%s/%s" % [path, file_name])
						if resource is Material:
							if resource.resource_name != "":
								all[resource.resource_name] = resource
							else:
								print("%s doesnt have a name!" % resource.resource_path)
				file_name = dir.get_next()
			dir.list_dir_end()
		else:
			printerr("Could not open directory: " + path)
