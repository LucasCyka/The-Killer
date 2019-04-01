extends "res://scripts/Traps.gd"


"""
	Lure traps. This kind of trap will modify the teenager's routine,
	making them follow a different path.
"""


var size = 10
var current_position = Vector2(0,0)
var trail = [] setget , get_trail
var previous_texture = null
#space between two traps
var spacement = 210
#if the trap is already being used by one or two teenagers
var is_used = false

#world nodes 
onready var current_texture = $Texture
onready var detection_radius = $Texture/DetectionRadius

#TODO: params like what kind of trap this is. Who can be affect by it?
#how many points does it cost? detection radius? etc...

#start animations
func _ready():
	type = TYPES.LURE
	current_texture.set_animation(str(id))
	#TODO: change the trap modifiers according to its id
	
#move the trap around the map and call the draw function
func _process(delta):
	if base == null:
		update()
		return
	elif trail.size() == size:
		#this trap is set and finished
		set_process(false)
		#signals
		detection_radius = get_children()
		for radius in detection_radius:
			radius.get_child(0).connect("body_entered",self,"on_radius")
			radius.get_child(0).connect("body_exited",self,"out_radius")
		
		ui.disconnect("new_trap",self,"exit")
			
		update()
		return
		
	var closest = base.get_closest_tile(tiles,get_global_mouse_position(),20)
	if closest == get_global_mouse_position():
		set_is_invalid_tile(true)
	else: set_is_invalid_tile(false)
	current_texture.global_position = Vector2(closest.x+25/2,closest.y+25/2)
	update()
	
#place or cancel traps
func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		#place traps
		if Input.is_action_just_pressed("ok_input"):
			if trail.size() < size and !is_used and !is_invalid_tile and !ui.is_ui_occupied:
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
				trail.append(current_texture.global_position)
				previous_texture = current_texture
				current_texture = current_texture.duplicate()
				add_child(current_texture)
		#cancel traps
		elif Input.is_action_just_pressed("cancel_input"):
			if trail.size() != size and !is_used:
				self.queue_free()

#draw lines between each trap placed, showing the path the player should walk
func _draw():
	if previous_texture == null or is_used: return
	if current_texture.global_position.distance_to(previous_texture.global_position) > spacement:
		#the spacemenet between the two are too big, show it tothe player.
		
		return
	elif trail.size() >1 and trail.size() < size:
		for trap in range(trail.size()):
			if trail[trap] != trail.back(): 
				var from = trail[trap]
				var to = trail[trap+1]
				
				draw_line(from,to,Color.red)
				
	#draw a line between the current texture and the previous one
	var from = previous_texture.global_position
	var to = current_texture.global_position
	draw_line(from,to,Color.red)

#check if the teenager entered the radius of the trap so he can be lured
func on_radius(body):
	if body.name == "KinematicTeenager" and !is_used:
		var teenager = body.get_parent()
		
		if trapped_teenagers.find(teenager) != -1:
			#the teenager has already been lured by this trap
			return
			
		if check_requirements(teenager):
			if lure_teenager(teenager):
				trapped_teenagers.append(teenager)
				if is_one_shot():
					 deactivate_trap()

#check if the teenager is leaving the trap radius
func out_radius(body):
	if is_used: return
	
	if body.name == "KinematicTeenager" and !is_used:
		var teenager = body.get_parent()
		teenager.remove_trap(self,false)

func get_trail():
	return trail

#remove a piece from the trail according to a position
#end return an updated trail
func remove_piece(pos):
	for piece in get_children():
		if piece.global_position == pos:
			piece.queue_free()
			trail.erase(pos)
			break
	return trail