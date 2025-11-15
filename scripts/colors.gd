@tool
class_name Colors

static var palette : ColorPalette = preload("res://colors/florentine24.tres")

static var white : Color:
	set(n_color):
		pass
	get():
		return palette.colors[0]

static var light_grey : Color:
	set(n_color):
		pass
	get():
		return palette.colors[1]

static var grey : Color:
	set(n_color):
		pass
	get():
		return palette.colors[2]
		
static var dark_grey : Color:
	set(n_color):
		pass
	get():
		return palette.colors[3]

static var black : Color:
	set(n_color):
		pass
	get():
		return palette.colors[4]

static var orange : Color:
	set(n_color):
		pass
	get():
		return palette.colors[10]

static var yellow : Color:
	set(n_color):
		pass
	get():
		return palette.colors[9]

static var peach : Color:
	set(n_color):
		pass
	get():
		return palette.colors[11]

static var tan : Color:
	set(n_color):
		pass
	get():
		return palette.colors[23]

static var lime_green : Color:
	set(n_color):
		pass
	get():
		return palette.colors[8]

static var green : Color:
	set(n_color):
		pass
	get():
		return palette.colors[7]

static var medium_green : Color:
	set(n_color):
		pass
	get():
		return palette.colors[6]
		
static var dark_green : Color:
	set(n_color):
		pass
	get():
		return palette.colors[5]
		
static var sky_blue : Color:
	set(n_color):
		pass
	get():
		return palette.colors[22]

static var light_blue : Color:
	set(n_color):
		pass
	get():
		return palette.colors[21]

static var blue : Color:
	set(n_color):
		pass
	get():
		return palette.colors[20]
		
static var dark_blue : Color:
	set(n_color):
		pass
	get():
		return palette.colors[19]

static var brown : Color:
	set(n_color):
		pass
	get():
		return palette.colors[24]

static var dark_brown : Color:
	set(n_color):
		pass
	get():
		return palette.colors[25]
		

static var purple : Color:
	set(n_color):
		pass
	get():
		return palette.colors[15]

static var dark_purple : Color:
	set(n_color):
		pass
	get():
		return palette.colors[16]
		
static var pink : Color:
	set(n_color):
		pass
	get():
		return palette.colors[13]

static func palette_from_string(color_palette : String) -> Array[Color]:
	# TODO: Probably dont use Materials for this but im lazy af
	var item_materials : Array[Color] = []
	for item_color in color_palette.split(","):
		var color_name = item_color.strip_edges()
		
		var material = Materials.list.all[color_name]
		assert(material, "Color doesnt exist!")
		var color : Color = material.next_pass.get_shader_parameter("polygon_color")
		item_materials.push_back(color)
		
	return item_materials

static func white_ramp() -> Array[Color]:
	return [
		palette.colors[1],
		palette.colors[2],
		palette.colors[3],
		palette.colors[4],
	]

static func green_ramp():
	return [
		palette.colors[5],
		palette.colors[6],
		palette.colors[7],
		palette.colors[8],
	]

static func red_ramp():
	return [
		palette.colors[9],
		palette.colors[10],
		palette.colors[11],
		palette.colors[12],
	]

static func pink_ramp():
	return [
		palette.colors[13],
		palette.colors[14],
		palette.colors[15],
		palette.colors[16],
	]

static func blue_ramp():
	return [
		palette.colors[17],
		palette.colors[18],
		palette.colors[19],
		palette.colors[20],
	]
	
static func light_blue_ramp():
	return [
		palette.colors[22],
		palette.colors[21],
		palette.colors[20],
		palette.colors[19],
	]

static func magenta_ramp():
	return [
		palette.colors[27],
		palette.colors[26],
		palette.colors[25],
		palette.colors[24],
	]
