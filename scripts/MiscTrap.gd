extends "res://scripts/Traps.gd"

"""
	Miscellaneous traps. They are placed in the world but they cause different
	reactions in the teenagers. They can scare, increase curiosity,
	hurt etc...
	
	Misc traps are not added to the teenager 'traps' array. They only cause
	effects like, enter panic, increase fear, curiosity etc...
"""

var is_placed = false
var is_used = false
var body_on_radius = null
#priotity system. This will replace other traps area of effect. 
#It goes from 0 to 10.
var priotity = [10]

#world nodes
onready var current_texture = $Texture
onready var detection_radius = $Texture/Area2D
onready var detection_spot_radius = $Texture/AreaSpot
onready var detection_wall = $Texture/VisibilityDetection

var effects = {
	0:[funcref(self,"enter_panic")],
	1:[funcref(self,"cripple")],
	2:[funcref(self,"cripple")]
	
}

func _ready():
	#change the textures acording to its ID
	current_texture.set_animation(str(id))
	
	#detection signals
	type = TYPES.MISC
	
	if not is_on_spot():
		detection_radius.connect("area_entered",self,"on_radius")
		detection_radius.connect("area_exited",self,"out_radius")
	else:
		detection_spot_radius.connect("area_entered",self,"on_radius")
		detection_spot_radius.connect("area_exited",self,"out_radius")

#move the trap around the map
func _process(delta):
	if base == null or is_placed:
		if is_placed and base != null and body_on_radius != null:
			var teen = body_on_radius.get_parent().get_parent()
			
			#if the teenager are in the same region, emit the signal
			if teen.is_indoor == is_indoor:
				if teen.is_object_visible(detection_wall):
					on_radius(body_on_radius)
					body_on_radius = null
		return
	
	var closest = base.get_closest_tile(tiles,get_global_mouse_position(),20)
	if closest == get_global_mouse_position():
		#the player can't place the trap here
		set_is_invalid_tile(true)
	else: set_is_invalid_tile(false)
	
	current_texture.global_position = Vector2(closest.x+25/2,closest.y+25/2)
		
#place or cancel traps
func _input(event):
	if Input.is_action_just_pressed("ok_input"):
		if not is_invalid_tile and not is_placed and not ui.is_ui_occupied:
			is_placed = true
			ui.disconnect("new_trap",self,"exit")
			#on radius  signal
			#detection_radius.connect("body_entered",self,"on_radius")
			
	elif Input.is_action_just_pressed("cancel_input"):
		if not is_placed:
			queue_free()

#check if a teenager activated this trap
func on_radius(area):
	var teen = null
	if area.name == "DetectionArea":
		teen = area.get_parent().get_parent()
		if !check_requirements(teen): return
		#check if the teenager has already falled for this trap.
		if trapped_teenagers.find(teen) != -1: return
	if area.name == "DetectionArea" and !is_used and is_placed:
		#check if the teenager can see the trap
		if teen.is_indoor != is_indoor or !teen.is_object_visible(detection_wall):
			#he can't see the trap now, but lets wait if he can see it later
			body_on_radius = area
			return
		#print(teen)
		#body.get_parent().set_trap(self)
		for effect in effects[id]:
			#apply each effect of this trap
			effect.call_func(teen)
			if oneshot:
				is_used = true
		trapped_teenagers.append(teen)
		
		#if the player may avoid this tile or not
		if not is_walkable():
			var pos = current_texture.global_position
			star.set_tile_weight(Vector2(pos.x,pos.y),10)
			star.set_tile_weight(Vector2(pos.x,pos.y+25),10)
			star.set_tile_weight(Vector2(pos.x,pos.y-25),10)
			star.set_tile_weight(Vector2(pos.x+25,pos.y),10)
			star.set_tile_weight(Vector2(pos.x-25,pos.y),10)
		
	elif area.name == "DetectionArea" and !is_used and !is_placed:
		#await for it to be placed then...
		body_on_radius = area
		
				
func out_radius(area):
	if area == body_on_radius:
		body_on_radius = null

















