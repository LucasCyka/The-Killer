extends "res://scripts/Traps.gd"


"""
	Lure traps. This kind of trap will modify the teenager's routine,
	making them follow a different path.
"""

var id = 0
var size = 10
var current_position = Vector2(0,0)
var traps = []
var previous_texture = null
#space between two traps
var spacement = 115

#world nodes 
onready var current_texture = $Texture

#the tilemap where luretraps can be placed
var tilemap = null

#start animations
func _ready():
	current_texture.set_animation(str(id))

#move the trap around the map
func _process(delta):
	if base == null or traps.size() == size:
		update()
		return
		
	var closest = base.get_closest_tile(tiles,get_global_mouse_position(),10000)
	current_texture.global_position = Vector2(closest.x,closest.y)
	update()
	
#place or cancel traps
func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if Input.is_action_just_pressed("ok_input"):
			if traps.size() < size:
				if previous_texture != null:
					#check if the distance between placements isn't too big
					if current_texture.global_position.distance_to(previous_texture.global_position) > spacement:
						#TODO: check if he connect to another trap, than
						#change the previous texture to it.
						return
					#check if there's another trap on that spot
					for trap in get_tree().get_nodes_in_group("lure"):
						if trap != current_texture and trap.global_position == current_texture.global_position:
							return
				#add traps
				traps.append(current_texture.global_position)
				previous_texture = current_texture
				current_texture = current_texture.duplicate()
				add_child(current_texture)
		elif Input.is_action_just_pressed("cancel_input"):
			if traps.size() != size:
				self.queue_free()

#draw lines between each trap placed, showing the path the player should walk
func _draw():
	if previous_texture == null: return
	if current_texture.global_position.distance_to(previous_texture.global_position) > spacement:
		#the spacemenet between the two are too big, show it tothe player.
		
		return
	elif traps.size() >1 and traps.size() < size:
		for trap in range(traps.size()):
			if traps[trap] != traps.back(): 
				var from = traps[trap]
				var to = traps[trap+1]
				
				draw_line(from,to,Color.red)
				
	#draw a line between the current texture and the previous one
	var from = previous_texture.global_position
	var to = current_texture.global_position
	draw_line(from,to,Color.red)




