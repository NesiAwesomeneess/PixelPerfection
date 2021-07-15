extends ViewportContainer

var low_res_camera

onready var viewport = $Viewport
onready var screen = get_viewport()

onready var game_size = viewport.size
onready var screen_size = screen.size

var viewport_size
var container_offset

onready var anchor = $Anchor
onready var hd_screen = $HD
export (int) var margin

var scale = 4

func _ready():
	
	
	scale = screen_size.x / game_size.x
	hd_screen.scale = Vector2(scale, scale)
	hd_screen.set_as_toplevel(true)
	
	var low_res_cams = get_tree().get_nodes_in_group("LowResCam")
	if low_res_cams.size() > 0:
		low_res_camera = low_res_cams[0]
	
	viewport_size = Vector2(game_size.x + margin, game_size.y + margin)
	viewport.size = viewport_size
	container_offset = (viewport_size/2)
	
	rect_scale = Vector2(scale, scale)
	anchor.set_as_toplevel(true)

func _process(_delta):
	if low_res_camera:
		var camera_pos = low_res_camera.global_position
		rect_position = (camera_pos - container_offset) * scale
		anchor.global_position = camera_pos * scale
