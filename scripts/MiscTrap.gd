extends "res://scripts/Traps.gd"

"""
	Miscellaneous traps. They are placed in the world but they cause different
	reactions in the teenagers. They can scare, increase curiosity,
	hurt etc...
"""

var id = 0
var is_placed = false
var is_used = false
var is_one_shot = false #if this trap can be used several times
var body_on_radius = null

#world nodes
onready var current_texture = $Texture
onready var detection_radius = $Texture/Area2D

var effects = {
	0:[funcref(self,"enter_panic")],
	1:[funcref(self,"enter_panic")]
	
}

func _ready():
	#TODO: change the textures acording to its ID
	#detection signals
	detection_radius.connect("body_entered",self,"on_radius")
	detection_radius.connect("body_exited",self,"on_radius")

#move the trap around the map
func _process(delta):
	if base == null or is_placed:
		if is_placed and base != null and body_on_radius != null:
			#if the teenager are in the same region, emit the signal
			if body_on_radius.get_parent().is_indoor == is_indoor:
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
func on_radius(body):
	if body.name == "KinematicTeenager" and !is_used and is_placed:
		#check if the teenager can see the trap
		if body.get_parent().is_indoor != is_indoor:
			#he can't see the trap now, but lets wait if he can see it later
			body_on_radius = body
			return
		
		#TODO: raycast from the teenager to the trap to ensure he really can 
		#see it...
		#body.get_parent().set_trap(self)
		for effect in effects[id]:
			#apply each effect of this trap
			effect.call_func(body.get_parent())
			if is_one_shot:
				is_used = true
	elif body.name == "KinematicTeenager" and !is_used and !is_placed:
		#await for it to be placed then...
		body_on_radius = body
		
				
func out_radius(body):
	if body == body_on_radius:
		body_on_radius = null

















