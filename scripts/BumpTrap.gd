extends "res://scripts/Traps.gd"

"""
	Bump trap. This trap will change the teenager state in their range of detection:
	It can be screams, 'bumps' on the wall etc...
"""

var id = 0

#the detection radius of the sound
var radius = [150]

#world nodes
onready var texture = $Texture

func _ready():
	#TODO: change the textures acording to its ID
	#TODO: change the type of tiles according to its ID
	#TODO: change the type of detection radius here...
	
	#I guess this won't work on the web version...
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

#move the trap around
func _process(delta):
	if base == null:
		return
	
	var closest = base.get_closest_tile(tiles,get_global_mouse_position(),20)
	if closest == get_global_mouse_position():
		#the player can't place the trap here
		set_is_invalid_tile(true)
	else: set_is_invalid_tile(false)
	
	texture.global_position =  Vector2(closest.x,closest.y)

func _input(event):
	if Input.is_action_just_pressed("cancel_input"):
		queue_free()
	elif Input.is_action_just_pressed("ok_input"):
		if is_invalid_tile:
			return
		
		#activate this trap.
		var teenagers = base.get_teenagers()
		
		for teenager in teenagers:
			var teen_pos = teenager.kinematic_teenager.global_position
			var distance = teen_pos.distance_to(texture.global_position)
			if distance < radius[id]:
				#TODO: check if he's inside a building
				startle_teenager(teenager)

func on_free():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)













