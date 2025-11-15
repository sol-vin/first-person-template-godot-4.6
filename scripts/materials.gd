@tool
extends Node

@export var list : MaterialsList = preload("res://textures/list.tres")


var white : Material:
	set(n_white):
		pass
	get():
		return list.all["White"]

var pink : Material:
	set(n_pink):
		pass
	get():
		return list.all["Pink"]

var dark_pink : Material:
	set(n_pink):
		pass
	get():
		return list.all["Dark Pink"]

var full_dark_pink : Material:
	set(n_pink):
		pass
	get():
		return list.all["Full Dark Pink"]

var full_orange : Material:
	set(n_pink):
		pass
	get():
		return list.all["Full Orange"]

var full_blue : Material:
	set(n_pink):
		pass
	get():
		return list.all["Full Blue"]

var red : Material:
	set(n_red):
		pass
	get():
		return list.all["Red"]
		
var blue : Material:
	set(n_blue):
		pass
	get():
		return list.all["Blue"]

var light_blue : Material:
	set(n_light_blue):
		pass
	get():
		return list.all["Light Blue"]

var light_grey : Material:
	set(n_light_grey):
		pass
	get():
		return list.all["Light Grey"]

var grey : Material:
	set(n_grey):
		pass
	get():
		return list.all["Grey"]
		
var dark_grey : Material:
	set(n_dark_grey):
		pass
	get():
		return list.all["Dark Grey"]
var brown : Material:
	set(n_brown):
		pass
	get():
		return list.all["Brown"]

var dark_brown : Material:
	set(n_brown):
		pass
	get():
		return list.all["Dark Brown"]

var yellow : Material:
	set(n_brown):
		pass
	get():
		return list.all["Yellow"]

func color(color_name : String):
	return list.all[color_name]

func list_from_string(color_list : String):
	var item_materials = []
	for item_color in color_list.split(","):
		var color_name = item_color.strip_edges()
		assert(list.all.has(color_name), "Material %s does not exist! for node %s" % [color_name, self.name])
		
		var material = Materials.list.all[color_name]
		item_materials.push_back(material)
	return item_materials
