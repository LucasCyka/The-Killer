extends "res://scripts/Traps.gd"

"""
	Miscellaneous traps. They are placed in the world but they cause different
	reactions in the teenagers. They can scare, increase curiosity,
	hurt etc...
"""

var id = 0
var is_placed = false
onready var current_texture = $Texture

var effects = {
	0:[funcref(self,"enter_panic")]
	
}

func _ready():
	#TODO: change the textures acording to its ID
	pass

#move the trap around the mpa
func _process(delta):
	if base == null or is_placed:
		return
		
	var closest = base.get_closest_tile(tiles,get_global_mouse_position(),10000)
	current_texture.global_position = Vector2(closest.x,closest.y)