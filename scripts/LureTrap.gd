extends "res://scripts/Traps.gd"


"""
	Lure traps. This kind of trap will modify the teenager's routine,
	making them follow a different path.
"""


var size = 10
var current_position = Vector2(0,0)
var trail = [] setget , get_trail
var previous_texture = null
var body_on_radius = []
#space between two traps
var spacement = 210
#if the trap is already being used by one or two teenagers
var is_used = false

#these dictionaries will store the trail a teenager currently is.
#it's only used by traps that aren't one-shot, so the teen can continue
#his trail from where he stopped when it's interrupted.
var trail_position = {}
var trail_section = {}

#world nodes 
onready var current_texture = $Texture
onready var detection_radius = $Texture/DetectionRadius
onready var detection_wall = $Texture/VisibilityDetection

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
		#for t in trail:
		#	print(t)
		#is_placed = true
		set_is_placed(true)
		set_process(false)
		current_texture.queue_free()
		current_texture = null
		#subtract the price of this trap from the game spendable points
		get_parent().points -= price
		#signals
		detection_radius = get_children()
		for radius in detection_radius:
			radius.get_node("DetectionRadius").connect("area_entered",self,"on_radius")
			radius.get_node("DetectionRadius").connect("area_exited",self,"out_radius")
		
		ui.disconnect("new_trap",self,"exit")
			
		update()
		return
		
	var closest = base.get_closest_tile(tiles,get_global_mouse_position(),20)
	if closest == get_global_mouse_position() or is_teenager_seeing_trap():
		set_is_invalid_tile(true)
	else: set_is_invalid_tile(false)
	current_texture.global_position = Vector2(closest.x+25/2,closest.y+25/2)
	update()

#check if close teenager can see the lure
func _physics_process(delta):
	if body_on_radius == [] or is_used:
		return
	
	for body in body_on_radius:
		var teen = body.get_parent()
		
		for piece in get_children():
			var detection = piece.get_node("VisibilityDetection")
			if teen.is_object_visible(detection):
				on_radius(body)
				break
	
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
	if previous_texture == null or is_used or current_texture == null: return
	if current_texture.global_position.distance_to(previous_texture.global_position) > spacement:
		#the spacemenet between the two is too big
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
func on_radius(area):
	if area.name == "DetectionArea" and !is_used:
		var teenager = area.get_parent()
		
		if trapped_teenagers.find(teenager) != -1:
			#the teenager has already been lured by this trap
			return
		
		var is_visible = false
		for piece in get_children():
			if teenager.is_object_visible(piece.get_node("VisibilityDetection")):
				is_visible = true
				break
		
		if !is_visible:
			#he can't see the lure yet
			if body_on_radius.find(area) == -1: body_on_radius.append(area)
			return
		
		if check_requirements(teenager):
			if lure_teenager(teenager):
				trapped_teenagers.append(teenager)
				if is_one_shot():
					 deactivate_trap()
				#play sound effect
				if sound != 'NULL':
					base.audio_system.play_2d_sound(sound,teenager.global_position)
				#is_used = true
		else:
			#the teen can't fall for this trap
			if body_on_radius.find(area) != -1: body_on_radius.erase(area)

#check if the teenager is leaving the trap radius
func out_radius(area):
	if is_used: return
	
	if body_on_radius.find(area) != -1: body_on_radius.erase(area)
	
	if area.name == "DetectionArea" and !is_used and is_one_shot():
		var teenager = area.get_parent()
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