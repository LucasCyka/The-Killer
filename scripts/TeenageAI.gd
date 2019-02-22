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

export (GENDER) var gender = GENDER.MALE
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








