extends Node

"""
	Player input and events.
"""

#world nodes
onready var camera = $camera

#params
const camera_speed = 420
const max_zoom = Vector2(0.2,0.2)
const min_zoom = Vector2(1,1)
const target_zoom = Vector2(0.1,0.1)

export var max_constraints = Vector2(9999,9999)
export var min_constraints = Vector2(-9999,-9999)

#init
func _ready():
	#TODO: set a limit for the camera movement
	pass

#camera movement
func _physics_process(delta):
	var movement = Vector2(0,0)
	
	var right = Input.is_action_pressed("Right")
	var left = Input.is_action_pressed("Left")
	var up = Input.is_action_pressed("Up")
	var down = Input.is_action_pressed("Down")
	movement.x = int(right) + (int(left) * -1)
	movement.y = int(down) + int(up) * -1
	move_camera_to(movement,delta)
	

#camera zoom-in/zoom-out
func _input(event):
	var zoom_level = Vector2(0,0)
	#TODO: remove this from here and put on the process function
	#so we can smooth the zoom using the lerp function.
	if event.is_action("ZoomOut") or event.is_action("ZoomIn"):
		if event.is_action("ZoomIn"):
			zoom_level = target_zoom
		elif event.is_action("ZoomOut"):
			zoom_level = target_zoom * -1
		else: zoom_level = Vector2(0,0)

		zoom_camera(zoom_level)

#move the camera to a given position
func move_camera_to(to,delta):
	var dir = to
	#apply constraints
	dir.x += -int(camera.global_position.x >= max_constraints.x and to.x == 1)
	dir.x += int(camera.global_position.x <= min_constraints.x and to.x == -1)
	dir.y += -int(camera.global_position.y >= max_constraints.y and to.y == 1)
	dir.y += int(camera.global_position.y <= min_constraints.y and to.y == -1)
	
	camera.global_position = camera.global_position + dir * camera_speed * delta
	
	
#change the current zoom level of the camera
func zoom_camera(zoom):
	if zoom == target_zoom and camera.get_zoom().x >= min_zoom.x:
		return false
	elif zoom == target_zoom * -1 and !camera.get_zoom().x >= max_zoom.x:
		return false
	else:
		#TODO: zoom smoothing
		camera.set_zoom(camera.get_zoom() + zoom)
		return true

