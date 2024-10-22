extends "res://scripts/Traps.gd"

"""
	Bump trap. This trap will change the teenager state in their range of detection:
	It can be screams, 'bumps' on the wall etc...
"""

#the detection radius of the sound
var radius = [150,100]
var show_radius = [false,true]

#defines how much far the teenager will look for the sound
const effect_area = [150,200]

#world nodes
onready var texture = $Texture

func _ready():
	#TODO: change the type of tiles according to its ID
	#TODO: change the type of detection radius here...
	
	#TODO: change the textures acording to its ID
	$Texture.play(str(id))
	
	type = TYPES.BUMP
	#I guess this won't work on the web version...
	#Correction: it works!
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if show_radius[id]:
		$Texture/radius.show()

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
				if check_requirements(teenager):
					startle_teenager(teenager,get_bump_position(teen_pos))
		#spend points for this trap
		get_parent().points -= price
		
		if sound != 'NULL':
			#play sound
			var audio = get_parent().audio_system
			audio.play_2d_sound(sound,$Texture.global_position)
		
		queue_free()

func on_free():
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

#get the position the teenager will search for the bump
func get_bump_position(teenager_pos):
	var direction = teenager_pos - texture.global_position
	direction = direction.normalized()
	
	var final_pos = (teenager_pos - direction*effect_area[0])
	
	return final_pos











