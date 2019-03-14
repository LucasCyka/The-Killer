extends Node2D

"""
	Controls the teenager AI.
"""

#teenager gender
enum GENDER {
	MALE,
	FEMALE
}

#AI Routine according to his ID
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
		27:"Waiting"
		
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
var current_routine = 0

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

export (GENDER) var gender = GENDER.MALE setget , get_gender
export var id = 0
export var speed = base_speed
#world nodes
onready var state_machine = $States
onready var kinematic_teenager = $KinematicTeenager
onready var teenager_anims = $KinematicTeenager/Animations

#initialize
func _ready():
	#start this npc routine
	generate_routine(get_node("Routine"))
	init_routine()
	update_animations()
	
	
func _process(delta):
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
	#TODO: use an A* algorithm
	var dir = to - kinematic_teenager.global_position
	dir = dir.normalized()
	
	
	if kinematic_teenager.global_position.distance_to(to) < 4:
		return true
	else:
		kinematic_teenager.move_and_slide(dir * speed)
		return false

#TODO: update animations according to its state, id etc...
func update_animations():
	if gender == GENDER.MALE:
		teenager_anims.play("MaleNormal")
	else:
		teenager_anims.play("FemaleNormal")

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

func set_fear(value):
	fear = value
	
	#increase score
	var fear_modifier = 2.5
	var level = get_parent().get_parent().get_level()
	var points = (score.get_score(level) + value * fear_modifier)
	score.set_score(level,int(points))
	#TODO: check if this new fear level will not trigger the panic mode

func get_fear():
	return fear

#returns the teenager's positon
func get_position():
	return kinematic_teenager.global_position

#this teenager has fall into a trap, change his modifers and update it.
func set_trap(value):
	traps.append(value)
	
	#apply modifiers
	set_fear(get_fear() + traps[0].fear)
	set_curiosity(get_curiosity() + traps[0].curiosity)
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
			break

#enable/unable slow modifier
func set_slow(value):
	slow = value
	
	if slow:
		speed -= speed * slow_modifier
	else:
		speed = base_speed
	
	
	