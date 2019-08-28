extends Node

"""
	Player input and events.
"""

signal changed_zoom
signal travel_finished

#world nodes
onready var camera = $camera

#params
const camera_speed = 420
const max_zoom = Vector2(0.2,0.2)
const min_zoom = Vector2(1,1)
const target_zoom = Vector2(0.1,0.1)
const max_super_zoom = Vector2(2,2)

export var max_constraints = Vector2(9999,9999)
export var min_constraints = Vector2(-9999,-9999)

#keep track os scroller at the edges of the screen being activated
var _scroll_left = false
var _scroll_right = false
var _scroll_up = false
var _scroll_down = false
var _scroller_timer = false

#automatically moves the camera to a given position
var is_travelling = false
var travel_position = Vector2(0,0)
var travel_speed = 10

#when the camera is on "super-zoom" mode. That means that the player can
#is zoomed out by a big amount. 
var super_zoom = false setget set_super_zoom

#init
func _ready():
	#connect edge scrollers signals
	$camera/Scrollers/AreaLeft.connect('mouse_entered',self,'update_scroller',['left',true])
	$camera/Scrollers/AreaLeft.connect('mouse_exited',self,'update_scroller',['left',false])
	$camera/Scrollers/AreaRight.connect('mouse_entered',self,'update_scroller',['right',true])
	$camera/Scrollers/AreaRight.connect('mouse_exited',self,'update_scroller',['right',false])
	$camera/Scrollers/AreaUp.connect('mouse_entered',self,'update_scroller',['up',true])
	$camera/Scrollers/AreaUp.connect('mouse_exited',self,'update_scroller',['up',false])
	$camera/Scrollers/AreaDown.connect('mouse_entered',self,'update_scroller',['down',true])
	$camera/Scrollers/AreaDown.connect('mouse_exited',self,'update_scroller',['down',false])
	$camera/Scrollers/ScrollerTimer.connect('timeout',self,'update_scroller',['','',true])
	
#camera movement
func _physics_process(delta):
	var movement = Vector2(0,0)
	if is_travelling:
		travel_camera_to(travel_position,travel_speed)
		return
	
	var right = Input.is_action_pressed("Right")
	var left = Input.is_action_pressed("Left")
	var up = Input.is_action_pressed("Up")
	var down = Input.is_action_pressed("Down")
	movement.x = int(right) + (int(left) * -1)
	movement.y = int(down) + int(up) * -1
	move_camera_to(movement,delta)
	
	if !left and !right and !up and !down:
		_move_camera_with_mouse(delta)

#camera zoom-in/zoom-out.
func _input(event):
	var zoom_level = Vector2(0,0)
	#TODO: remove this from here and put on the process function
	#so we can smooth the zoom using the lerp function.
	if event.is_action("ZoomOut") or event.is_action("ZoomIn"):
		if event.is_action("ZoomIn"):
			zoom_level = target_zoom
		elif event.is_action("ZoomOut"):
			zoom_level = target_zoom * -1
		else: 
			zoom_level = Vector2(0,0)
			settings.background_db = 5

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
	
#change the current zoom level of the camera. also increase/decrease 
#background noises as the player approaches/leave the level.
func zoom_camera(zoom):
	if zoom == target_zoom and camera.get_zoom().x >= min_zoom.x:
		return false
	elif zoom == target_zoom * -1 and !camera.get_zoom().x >= max_zoom.x:
		return false
	elif super_zoom:
		return false
	else:
		#TODO: zoom smoothing
		camera.set_zoom(camera.get_zoom() + zoom)
		
		#background noise
		if camera.get_zoom().x == 1:
			settings.background_db = 5
		elif common.is_float_equal(camera.get_zoom().x,0.6):
			settings.background_db = 10
		elif common.is_float_equal(camera.get_zoom().x,0.4):
			settings.background_db = 15
		
		emit_signal("changed_zoom")
		
		return true

#will detect when the player is moving the camera by hovering the edges
#of the screen.
func _move_camera_with_mouse(delta):
	var movement = Vector2(0,0)
	
	movement.x = int(_scroll_right) + (int(_scroll_left) * -1)
	movement.y = int(_scroll_down) + int(_scroll_up) * -1
	
	if movement == Vector2(0,0):
		_scroller_timer = false
		$camera/Scrollers/ScrollerTimer.stop()
	elif movement != Vector2(0,0) and _scroller_timer:
		move_camera_to(movement,delta)

#activate/deactivate scrollers on the edge of the screen
func update_scroller(scroller,value,timer=false):
	if timer:
		_scroller_timer = true
		return
	
	match scroller:
		'left':
			_scroll_left = value
		'right':
			_scroll_right = value
		'up':
			_scroll_up = value
		'down':
			_scroll_down = value
		_:
			_scroller_timer = false
			return
	
	$camera/Scrollers/ScrollerTimer.start()

#move the camera smoothly to a given location
func travel_camera_to(to,speed=10):
	travel_position = to
	travel_speed = speed
	is_travelling = true
	
	var dir = to - camera.global_position
	dir = dir.normalized()
	var dis = camera.global_position.distance_to(to)
	
	if dis > 10:
		camera.global_position += dir * speed  
	else:
		emit_signal("travel_finished")
		is_travelling = false
	
#super zoom out/in
func set_super_zoom(value):
	super_zoom = value
	
	if super_zoom:
		camera.set_zoom(max_super_zoom)
		settings.background_db = -5
	else:
		camera.set_zoom(min_zoom)
		settings.background_db = 5
		pass





