extends "res://scripts/Player.gd"

"""
	Player input and events.
"""

#world nodes
onready var camera = $camera

#params
const camera_speed = 420
const max_zoom = Vector2(0.5,0.5)
const min_zoom = Vector2(2,2)
const target_zoom = Vector2(0.1,0.1)

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
	camera.global_position = camera.global_position + to * camera_speed * delta

#change the current zoom level of the camera
func zoom_camera(zoom):
	if zoom == target_zoom and camera.get_zoom().x >= min_zoom.x:
		return false
	elif zoom == target_zoom * -1 and !camera.get_zoom().x >= max_zoom.x:
		return false
	else:
		#zoom smoothing
		camera.set_zoom(camera.get_zoom() + zoom)
		return true


