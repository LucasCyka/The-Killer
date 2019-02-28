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
#notice that this routine can be blocken any time of the AI is lured
#or the state machine decides so.
var routines = {
	0:{"state":['Moving','Waiting','Moving'],"pos":[Vector2(430,344),Vector2(563,364),Vector2(100,100)],"time":[10,10,10]},
	
	1:{"state":['Moving','Moving'],"pos":[Vector2(490,341),Vector2(448,65)],"time":[10,10]}
}

#animations for wich teenager
var animations = {}
var current_routine = 0

#teenager's modifiers
var curiosity = 0 setget set_curiosity,get_curiosity
var fear = 0 setget set_fear,get_fear

#the traps the teenagers has just falled to. Null is no trap.
var traps = []

export (GENDER) var gender = GENDER.MALE setget , get_gender
export var id = 0
export var speed = 70
#world nodes
onready var state_machine = $States
onready var kinematic_teenager = $KinematicTeenager
onready var teenager_anims = $KinematicTeenager/Animations

#initialize
func _ready():
	#start this npc routine
	init_routine()
	update_animations()
	
func _process(delta):
	#updates the debug label
	$KinematicTeenager/Animations/DebugState.text = state_machine.get_current_state()
	#debug progress bar
	if state_machine.get_current_state() == 'Waiting':
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

#move to a given position.
#returns true if the player arrived at the destination.
func walk(to):
	#TODO: use an A* algorithm
	var dir = to - kinematic_teenager.global_position
	dir = dir.normalized()
	kinematic_teenager.move_and_slide(dir * speed)
	
	
	if kinematic_teenager.global_position.distance_to(to) < 4:
		return true
	else:
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








