extends Position2D

onready var parent = get_parent()

export (float) var cam_ahead_x = 0.8
export (float) var cam_ahead_y = 0.8
export (bool) var Dynamic_Camera_Offset = false

var initial_camera_offset_x
var game_window_size = Vector2()


func show_screen_sizes():
	print("Game window size:   ", game_window_size)


func _ready():
	initial_camera_offset_x = $CameraOffset.position.x
	game_window_size = Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height"))
	show_screen_sizes()
	update_pivot_angle()
	

func _physics_process(delta):
	update_pivot_angle()


func dynamic_camera_offset():
	# Compute camera ahead offset based on angle direction
	# Probably we somehow need to take in account the 
	# character size to keep character always in screen.
	# Or at least centered in character center of gravity
	# not on it's feet.
	var ahead_x = abs(game_window_size.x * cos(rotation)) * cam_ahead_x * 0.5
	var ahead_y = abs(game_window_size.y * sin(rotation)) * cam_ahead_y * 0.5
	var result = ahead_x + ahead_y
	
	if not Dynamic_Camera_Offset:
		result = initial_camera_offset_x

	return result
	
func update_pivot_angle():
	rotation = parent.look_direction.angle()
