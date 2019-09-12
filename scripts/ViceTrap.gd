extends "res://scripts/Traps.gd"

"""
	Vice traps. This traps are placed in the world will change the teenager's
	modifiers.
"""

var effects = {
	0:[funcref(self,"decrease_speed")],
	1:[funcref(self,"cause_diarrhea")]
	
}
var is_used = false
var body_on_radius = null

#world nodes
onready var texture = $Texture
onready var radius = $Texture/DetectionRadius
onready var detection_wall = $Texture/VisibilityDetection

func _ready():
	#TODO: change the textures acording to its ID
	#on radius signal
	type = TYPES.VICE
	radius.connect("area_entered",self,"_on_radius")
	radius.connect("area_exited",self,"_out_radius")

#move the trap around the map
func _process(delta):
	if base == null or is_placed:
		if is_placed and body_on_radius != null and !is_used:
			var teenager = body_on_radius.get_parent()
			#this trap is on the teenager radius. If he's both are in the
			#same location (indoor or outdoor) emit the signal
			if teenager.is_indoor == is_indoor and teenager.is_object_visible(detection_wall):
				_on_radius(body_on_radius)
				body_on_radius = null
		return
	
	var closest = base.get_closest_tile(tiles,get_global_mouse_position(),20)
	if closest == get_global_mouse_position() or is_teenager_seeing_trap():
		#the player can't place the trap here
		set_is_invalid_tile(true)
	else: set_is_invalid_tile(false)
	
	texture.global_position =  Vector2(closest.x+25/2,closest.y+25/2)

func _input(event):
	if Input.is_action_just_pressed("ok_input"):
		if not is_invalid_tile and not is_placed:
			#is_placed = true
			set_is_placed(true)
			#set_process(false)
			ui.disconnect("new_trap",self,"exit")
			#subtract this trap price
			get_parent().points -= price
			#on radius signal
			#radius.connect("body_entered",self,"_on_radius")
			
	elif Input.is_action_just_pressed("cancel_input"):
		#remove the trap if it's not placed yet when the player hits cancel
		if not is_placed:
			queue_free()

#when something entered this trap radius. Check if it's the player then do 
#its effects
#TODO: raycast to see if the player can really see the trap
func _on_radius(area):
	var teenager = null
	if area.name == "DetectionArea":
		teenager = area.get_parent()
		if !check_requirements(area.get_parent().get_parent()): return
		
	if area.name == "DetectionArea" and is_placed and !is_used:
		#check if the teenager can see the trap
		if teenager.is_indoor != is_indoor or !teenager.is_object_visible(detection_wall):
			#he can't see the trap now, but lets wait if he can see it later
			body_on_radius = area
			return
		#is_used = true
		#set_process(false)
#		body.get_parent().set_trap(self)
		if activate_vice(teenager):
			deactivate_trap()
			#is_used = true
			#set_process(false)
			#TODO: custom function to deactivate a trap
	elif area.name == "DetectionArea" and !is_placed and !is_used:
		#this trap has not been placed yet, but let's wait if it does later on
		body_on_radius = area
		#for effect in effects[id]:
			#apply each effect of this trap
			#TODO: those effects should be applied inside the OnVice State
			#effect.call_func(body.get_parent())

func _out_radius(area):
	if body_on_radius == area:
		body_on_radius = null









