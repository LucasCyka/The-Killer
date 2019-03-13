extends "res://scripts/Traps.gd"

"""
	Vice traps. This traps are placed in the world will change the teenager's
	modifiers.
"""

var id = 0

var effects = {
	0:[funcref(funcref(self,"cause_vice"),self,"decrease_speed")],
	1:[funcref(self,"decrease_speed")]
	
}
var is_placed = false
var is_used = false

#world nodes
onready var texture = $Texture
onready var radius = $Texture/DetectionRadius

func _ready():
	#TODO: change the textures acording to its ID
	pass

#move the trap around the map
func _process(delta):
	if base == null or is_placed:
		return
	
	var closest = base.get_closest_tile(tiles,get_global_mouse_position(),20)
	if closest == get_global_mouse_position():
		#the player can't place the trap here
		set_is_invalid_tile(true)
	else: set_is_invalid_tile(false)
	
	texture.global_position =  Vector2(closest.x,closest.y)

func _input(event):
	if Input.is_action_just_pressed("ok_input"):
		if not is_invalid_tile and not is_placed:
			is_placed = true
			set_process(false)
			ui.disconnect("new_trap",self,"exit")
			#on radius signal
			radius.connect("body_entered",self,"_on_radius")
			
	elif Input.is_action_just_pressed("cancel_input"):
		#remove the trap if it's not placed yet when the player hits cancel
		if not is_placed:
			queue_free()

#when something entered this trap radius. Check if it's the player then do 
#its effects
func _on_radius(body):
	if body.name == "KinematicTeenager":
		is_used = true
		for effect in effects[id]:
			#apply each effect of this trap
			#TODO: those effects should be applied inside the OnVice State
			effect.call_func(body.get_parent())
	body.get_parent().set_trap(self)

