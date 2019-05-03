extends Node2D

"""
	Controls the teenager AI.
"""

#teenager gender
enum GENDER {
	MALE,
	FEMALE
}

#AI Routine according to his ID. A new ID should be added everytime a new 
#character is implemented in the game.
#notice that this routine can be blocken any time the AI is lured
#or the state machine decides so.
var routines = {
	0:{"state":[],"pos":[],"time":[]},
	
	1:{"state":[],"pos":[],"time":[]},
	
	2:{"state":[],"pos":[],"time":[]}
}

#dictionary for the tilemap that will genearate new routines
var routine_dictionary = {
	"state":{
		
		26:"Moving",
		27:"Waiting",
		33:"Talking",
		35:"Sleeping"
		
	},
	"time":{
		28:2,
		29:5,
		30:10,
		31:15,
		32:20
	}
}

#animations for wich teenager
var animations = {}

#it's true when the teen needs to execute an animation from a state 'activity'
var state_animation = false
var current_routine = 0
var last_routine = 0
var is_routine_paused = false
var saw_player = false
var is_indoor = false setget set_is_indoor
var is_escaping = false
var facing_direction = Vector2(1,0)
#used for pathfinding:
var current_path = []
var current_target = Vector2(-666,-666)

#teenager's modifiers
var curiosity = 0 setget set_curiosity,get_curiosity
var fear = 0 setget set_fear,get_fear
var slow = false setget set_slow
var fast = false
var horny = false

const slow_modifier = 0.5
const fast_modifier = 1.5
const base_speed = 60

#the traps the teenagers has just falled to. Null is no trap.
var traps = []
var current_trap = 0

export (GENDER) var gender = GENDER.MALE setget , get_gender
export var id = 0
export var speed = base_speed
#world nodes
onready var state_machine = $States
onready var kinematic_teenager = $KinematicTeenager
onready var teenager_anims = $KinematicTeenager/Animations
onready var wall_cast = $KinematicTeenager/DetectionArea/WallCast
onready var detection_area = $KinematicTeenager/DetectionArea

#initialize
func _ready():
	#start this npc routine
	generate_routine(get_node("Routines/Routine"))
	init_routine()
	generate_animations()
	#update_animations()
	
func _process(delta):
	if not is_routine_paused:
		#decrease the teenager's modifiers when he's in routine mode.
		decrease_modifiers()
	update_animations()
	
#	print(traps)
	#updates the debug label
	$KinematicTeenager/Animations/DebugState.text = state_machine.get_current_state()
	#debug progress bar
	if state_machine.get_current_state() == 'Waiting':
		$KinematicTeenager/Animations/StateProgress.show()
	elif state_machine.get_current_state() == 'OnVice':
		$KinematicTeenager/Animations/StateProgress.show()
	else: $KinematicTeenager/Animations/StateProgress.hide()

#init the routine for the first time
func init_routine():
	state_machine.execute_routine(routines[id]["state"][current_routine],
	routines[id]["pos"][current_routine],
	routines[id]["time"][current_routine])

#go to the next routine, if it's available. If not, then, restart it over.
func next_routine():
	if routines[id]["state"].size() == 0:
		print("There are not routines programmed for this teenager.")
		print("He'll remain on 'idle state' until something happens")
		return
	elif routines[id]["state"].size()-1 == current_routine:
		#restart the routine again
		current_routine = 0
	else:
		#execute next routine
		current_routine += 1
	
	#print(current_routine)
	state_machine.execute_routine(routines[id]["state"][current_routine],
	routines[id]["pos"][current_routine],
	routines[id]["time"][current_routine])

#save the current routine for when it's resumed
func pause_routine():
	is_routine_paused = true
	last_routine = current_routine

#resume the last routine
func resume_routine():
	is_routine_paused = false
	
	state_machine.execute_routine(routines[id]["state"][last_routine],
	routines[id]["pos"][last_routine],
	routines[id]["time"][last_routine])

#create a routine for this teenager using a 'routine tilemap'
func generate_routine(routine_map):
	if routine_map.get_used_cells().size() < 2:
		print("not enough tiles on the routine tilemap.")
		return
		
	#get the number of actions in this routine
	var num = routine_map.get_used_cells().size() / 3
	
	#generate each routine according to their ids
	for _id in range(num):
		for tile in routine_map.get_used_cells():
			if routine_map.get_cell(tile.x,tile.y) == _id:
				#the tiles for this routine had been found, generate it!
				#routine tilamap configuration:
				#CENTER: routine
				#LEFT: id
				#RIGHT: time
				var _routine = routine_map.get_cell(tile.x+1,tile.y)
				var _time = routine_map.get_cell(tile.x+2,tile.y)
				var _position = routine_map.map_to_world(Vector2(tile.x+1,tile.y))
				
				#insert each action in their routine spot
				routines[id]["state"].insert(_id,routine_dictionary["state"][_routine])
				routines[id]["time"].insert(_id,routine_dictionary["time"][_time])
				routines[id]["pos"].insert(_id,_position)
				
				break

#move to a given position.
#returns true if the player arrived at the destination.
func walk(to):
	var distance = kinematic_teenager.global_position.distance_to(to)
	var from = kinematic_teenager.global_position
	var dir = Vector2(0,0)
	
	if distance > 10:
		if current_target != to:
			current_target =  to
			current_path = star.find_path(from,to)
		
		if current_path.size() == 0:
			current_target = Vector2(-666,-666)
			current_path = []
			return true
		elif current_path.size() < 2:
			current_path = []
			return true
		else:
			if current_path[1].distance_to(from) < 2:
				current_path.remove(1)
				return false
				
		dir = current_path[1] - from
		dir = dir.normalized()
		
		kinematic_teenager.move_and_slide(dir * speed)
		
		#get the direction the teenager is facing
		facing_direction = dir.round()
		#for some reason godot is returning '-0' sometimes... why?
		if facing_direction.x == -0: facing_direction.x = 0
		elif facing_direction.y == -0: facing_direction.y = 0
		
		return false
	else:
		return true

#TODO: update animations according to its state, id etc...
func update_animations():
	if animations == {}:
		#wait for it to be generated
		return
	
	if not state_animation:
		teenager_anims.play(animations[id]['Moving'][facing_direction]['anim'])
		teenager_anims.set_flip_h(animations[id]['Moving'][facing_direction]['flip'])
	else:
		teenager_anims.play(animations[id]['Idle'][facing_direction]['anim'])
		teenager_anims.set_flip_h(animations[id]['Idle'][facing_direction]['flip'])

#fill a dictionary with animations from the AnimatedSprite resource
#TODO: diagonal animations?
func generate_animations():
	var final_dictionary = {}
	
	for anim in teenager_anims.get_sprite_frames().get_animation_names():
		#anim name layout:
		#ID:State-Direction
		
		#anim indentifier
		var _id = anim
		_id.erase(anim.findn(':'),anim.length())
		
		#anim state
		var _state = anim
		_state.erase(anim.findn('-'),anim.length())
		_state.erase(anim.findn(_id),_id.length()+1)
		
		#anim direction
		#TODO: diagonals go here
		var dir = anim
		
		if dir.find('Up') != -1:
			dir = Vector2(0,-1)
		elif dir.find('Down') != -1:
			dir = Vector2(0,1)
		elif dir.find('Side') != -1:
			dir = Vector2(1,0)
			
			
		var new_dict = {int(_id):{_state:{dir:{'anim':anim,'flip':false}}}}
		
		if final_dictionary.keys().find(int(_id)) == -1 or final_dictionary[int(_id)].keys().find(_state) == -1:
			#add the basic layout for this animation id
			common.merge_dict(final_dictionary,new_dict)
		elif final_dictionary[int(_id)][_state].keys().find(dir) == -1:
			#basic layout already there, just fill the remaining data
			final_dictionary[int(_id)][_state][dir] = {'anim':anim,'flip':false}
			
			if dir == Vector2(1,0):
				#duplicate this animation for the left siding
				final_dictionary[int(_id)][_state][Vector2(-1,0)] = {'anim':anim,'flip':true}
		animations = final_dictionary

#return a string according to the gender
func get_gender():
	if gender == GENDER.MALE:
		return "MALE"
	else:
		return "FEMALE"

func set_curiosity(value):
	curiosity = value

func get_curiosity():
	return curiosity

#params:
#value = amount of fear points
#cause_panic = if this new value can cause panic on the teenager.
func set_fear(value,cause_panic=true,add_points=true):
	fear = value
	
	#increase score
	var fear_modifier = 2.5
	var level = get_parent().get_parent().get_level()
	var points = (score.get_score(level) + value * fear_modifier)
	if add_points: score.set_score(level,int(points))
	
	if not cause_panic: return
	if get_fear() > get_curiosity():
		if state_machine.check_forced_state('Panic'):
			state_machine.set_state_queue('Panic')
	
func get_fear():
	return fear

#returns the teenager's positon
func get_position():
	return kinematic_teenager.global_position

func decrease_modifiers():
	if get_fear() > 0:
		set_fear(get_fear() - 0.01,true,false)
	
	if get_curiosity() > 0:
		set_curiosity(get_curiosity() - 0.01)
		
	#TODO: set a proper timer for decreasing modifiers
	#TODO: decrease other modifiers like, slow, horny etc...

#this teenager has fall into a trap, change his modifers and update it.
func set_trap(value):
	traps.append(value)
	current_trap = traps.size()-1
	
	#apply modifiers
	set_curiosity(get_curiosity() + traps[current_trap].curiosity)
	set_fear(get_fear() + traps[current_trap].fear)
	"""
	if value == null:
		#this trap is no more!
		trap[0].queue_free()
		trap.append(value)
		return
	trap = value
		
	#apply modifiers
	set_fear(get_fear() + trap.fear)
	set_curiosity(get_curiosity() + trap.curiosity)
	#TODO: the AI modifiers needs to decrease automatically
	"""

func get_traps():
	if traps == []:
		return []
	else:
		return traps
		
func remove_trap(value,free):
	for trap in traps:
		if trap == value:
			if free:
				trap.queue_free()
			traps.erase(trap)
			current_trap -= 1 
			break

#enable/unable slow modifier
func set_slow(value):
	slow = value
	
	if slow:
		speed -= speed * slow_modifier
	else:
		speed = base_speed

func set_is_indoor(value):
	is_indoor = value
	
	#debug labels
	if is_indoor:
		$KinematicTeenager/Animations/DebugState2.text = "indoor"
	else:
		$KinematicTeenager/Animations/DebugState2.text = "outdoor"

#check if the teen can see an object. Will return false if the object is being
#obstructed by walls.
func is_object_visible(object):
	wall_cast.set_cast_to(object.global_position - wall_cast.global_position)
	wall_cast.force_raycast_update()
	
	if wall_cast.is_colliding():
		return wall_cast.get_collider().name == object.name














