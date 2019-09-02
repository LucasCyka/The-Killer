extends Node2D

"""
	Controls the teenager AI.
"""

#when emmited the body of this teen will transformed into a trap
signal recover_teen

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
	
	2:{"state":[],"pos":[],"time":[]},
	
	3:{"state":[],"pos":[],"time":[]}
}

#dictionary for the tilemap that will genearate new routines
var routine_dictionary = {
	"state":{
		
		26:"Moving",
		27:"Waiting",
		33:"Talking",
		35:"Sleeping",
		36:"OnBed",
		41:"OnPicNic",
		42:"EatingTable",
		43:"SittingFloor",
		44:"Fishing"
		
	},
	"time":{
		28:2,
		29:5,
		30:10,
		31:15,
		32:20,
		37:30,
		38:40,
		39:50,
		40:60,
		45:120
	}
}

#animations for wich teenager
var animations = {}

#traits and temporary effects are stored here
var traits = {}

enum TRAITS {
	EMPTY = 0,
	SLOW = 1,
	FAST = 2,
	HORNY = 3,
	DIARRHEA = 4,
	FINAL_GIRL = 5
}

#it's true when the teen needs to execute an animation from a state 'activity'
var state_animation = false
var custom_animation = null
var is_tired = false
var queue_sleep = false
var remaining_sleep_time = 0
var current_routine = 0
var last_routine = 0
var is_routine_paused = false
var saw_player = false
var is_indoor = false setget set_is_indoor
var is_escaping = false
var is_talking = false
var is_thinking = false
var facing_direction = Vector2(1,0)
var custom_balloons = []
var lover = null
var was_in_love = false
var was_in_bathroom = false
var checked_light = false
var is_immune = false
var is_moving = false setget set_is_moving
var indoor_detection = null
var last_tile = null

#used for pathfinding:
var current_path = []
var current_target = Vector2(-666,-666)

#teenager's modifiers/effects
var curiosity = 0 setget set_curiosity,get_curiosity
var fear = 0 setget set_fear,get_fear
var slow = false setget set_slow
var fast = false setget set_fast
var horny = false setget set_horny
var diarrhea = false setget set_diarrhea

const slow_modifier = 0.3
const fast_modifier = 0.3
const base_speed = 50
const fast_effect_duration = 100
const normal_effect_duration = 500
const slow_effect_duration = 700

#the traps the teenagers has just falled to. Null is no trap.
var traps = []
var current_trap = 0

export (GENDER) var gender = GENDER.MALE setget , get_gender
export var id = 0
export var speed = base_speed setget set_speed
export var sleep_time = 1080
export var wake_time = 420
export var sleep_hours = 5
export var is_talkative = true

#the values below are used when this teen becomes a death trap
export (Texture) var death_icon
export (Texture) var death_trap1
export (Texture) var death_trap2
export (Texture) var death_trap3

#portraits used for in the UI
export (Texture) var portrait_neutral
export (Texture) var portrait_fear
export (Texture) var portrait_panic
export (Texture) var mugshot

#teen's lover
export (NodePath) var lover_path = ''

#name of this teen
export var teen_name = "Name Surname"

#traits
export (PoolIntArray) var teen_traits

#world nodes
onready var state_machine = $States
onready var kinematic_teenager =  self
onready var teenager_anims = $Animations
onready var dead_anims = $DeadAnimations
onready var wall_cast = $DetectionArea/WallCast
onready var detection_area = $DetectionArea
onready var balloon_timer = $Balloon/BalloonTimer

#initialize
func _ready():
	#start this npc routine
	generate_routine(get_node("Routines/Routine"))
	init_routine()
	generate_animations()
	update_talking_balloon()
	update_thinking_balloon()
	add_traits(teen_traits,true)
	init_lover(lover_path)
	
func _process(delta):
	if not is_routine_paused:
		#decrease the teenager's modifiers when he's in routine mode.
		decrease_modifiers()
	update_animations()
	check_tiredness()
	check_love()
	check_lights()
	check_bowels()
	init_indoor_detection()
#	print(speed)
#	print(traps)
	#updates the debug label
	$Animations/DebugState.text = state_machine.get_current_state()
	#debug progress bar
	"""
	match state_machine.get_current_state():
		'Waiting':
			$Animations/StateProgress.show()
		'OnVice':
			$Animations/StateProgress.show()
		'Talking':
			$Animations/StateProgress.show()
		'OnBed':
			$Animations/StateProgress.show()
		'OnPicNic':
			$Animations/StateProgress.show()
		'EatingTable':
			$Animations/StateProgress.show()
		'SittingFloor':
			$Animations/StateProgress.show()
		'Fishing':
			$Animations/StateProgress.show()
		'Sleeping':
			$Animations/StateProgress.show()
		_:
			$Animations/StateProgress.hide()
	"""
			

#init the routine for the first time
func init_routine():
	state_machine.execute_routine(routines[id]["state"][current_routine],
	routines[id]["pos"][current_routine],
	routines[id]["time"][current_routine])

#initialize the system that checks if a teen is indoor or outdoor
func init_indoor_detection():
	var game = get_parent().get_parent()
	var tiles = game.get_pathfinding_tile()
	
	if last_tile == null:
		last_tile = tiles.world_to_map(global_position)
		return
	elif last_tile == tiles.world_to_map(global_position):
		return
	
	indoor_detection = game.get_indoor_detection()
	indoor_detection.set_teen_indoor(self)
	last_tile = tiles.world_to_map(global_position)

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
		
		if not check_overlapping_teens():
			return false
		
		kinematic_teenager.move_and_slide(dir * speed)
		set_is_moving(true)
		
		if abs(dir.round().x) == 1 and abs(dir.round().y) == 1:
			#workaround for walking problem
			return
		
		#get the direction the teenager is facing
		facing_direction = dir.round()
		#for some reason godot is returning '-0' sometimes... why?
		if facing_direction.x == -0: facing_direction.x = 0
		elif facing_direction.y == -0: facing_direction.y = 0
		
		
		return false
	else:
		return true


#update animations according to its state, id etc...
func update_animations():
	if animations == {}:
		#wait for it to be generated
		return
	
	var state = state_machine.get_current_state()
	
	if not state_animation and custom_animation == null:
		teenager_anims.play(animations[id]['Moving'][facing_direction]['anim'])
		teenager_anims.set_flip_h(animations[id]['Moving'][facing_direction]['flip'])
	elif custom_animation != null:
		var _name = custom_animation.name
		#execute the custom animation
		teenager_anims.play(animations[id][_name][facing_direction]['anim'])
		teenager_anims.set_flip_h(animations[id][_name][facing_direction]['flip'])
	else:
		#TODO: replace the IDLE by the name of the state
		teenager_anims.play(animations[id][state][facing_direction]['anim'])
		teenager_anims.set_flip_h(animations[id][state][facing_direction]['flip'])

#show talking balloons over the teen's head.
#PARAMS: Timer = true when called using a timer
		 #Special = this ballon needs a special icon anim.
func update_talking_balloon(timer=false,specials=[]):
	#this timer will clear the balloons over the teen's head from time to time
	if !$Balloon/BalloonTimer.is_connected('timeout',self,'update_talking_balloon'):
		$Balloon/BalloonTimer.connect('timeout',self,'update_talking_balloon',[true,[]])
		$Balloon/BalloonTimer.set_wait_time(2)
		$Balloon/BalloonTimer.start()
		return
	
	if is_talking and timer and specials == [] and !custom_balloons:
		if $Balloon.is_visible():
			$Balloon.hide()
		else:
			#TODO: check if someone is close before talking
			$Balloon.show()
			$Balloon.play("talking")
			$Balloon/Icon.play(_get_random_ballon_icon())
			$Balloon/Icon.show()
			$Balloon/Specials.hide()
	elif !timer and specials != []:
		#single custom balloon icon
		$Balloon.show()
		$Balloon.play("talking")
		$Balloon/Icon.hide()
		$Balloon/Specials.show()
		$Balloon/Specials.play(specials[0])
		$Balloon/BalloonTimer.stop()
		$Balloon/BalloonTimer.start()
	elif timer and custom_balloons and is_talking:
		#custom balloon from an list
		if $Balloon.is_visible():
			$Balloon.hide()
			return
		$Balloon.show()
		$Balloon.play("talking")
		$Balloon/Icon.hide()
		$Balloon/Specials.show()
		$Balloon/Specials.play(_get_random_ballon_icon(true))
	else:
		if !is_thinking and !is_talking:
			$Balloon.hide()
	
#show talking balloons over the teen's head.
#PARAMS: Timer = true when called using a timer
		#Special = this ballon needs a special icon anim.
func update_thinking_balloon(timer=false,specials=[]):
	#this timer will clear the balloons over the teen's head from time to time
	if !$Balloon/BalloonTimer.is_connected('timeout',self,'update_thinking_balloon'):
		$Balloon/BalloonTimer.connect('timeout',self,'update_thinking_balloon',[true,[]])
		$Balloon/BalloonTimer.set_wait_time(2)
		$Balloon/BalloonTimer.start()
		return
	
	if is_thinking and timer and specials == [] and !custom_balloons:
		if $Balloon.is_visible():
			$Balloon.hide()
		else:
			$Balloon.show()
			$Balloon.play("thinking")
			$Balloon/Icon.play(_get_random_ballon_icon())
			$Balloon/Icon.show()
			$Balloon/Specials.hide()
	elif !timer and specials != []:
		#single custom balloon icon
		$Balloon.show()
		$Balloon.play("thinking")
		$Balloon/Icon.hide()
		$Balloon/Specials.show()
		$Balloon/Specials.play(specials[0])
		$Balloon/BalloonTimer.stop()
		$Balloon/BalloonTimer.start()
	elif timer and custom_balloons and is_thinking:
		#custom balloon from an list
		if $Balloon.is_visible():
			$Balloon.hide()
			return
		$Balloon.show()
		$Balloon.play("thinking")
		$Balloon/Icon.hide()
		$Balloon/Specials.show()
		$Balloon/Specials.play(_get_random_ballon_icon(true))
	else:
		if !is_thinking and !is_talking:
			$Balloon.hide()
	
	
#get a random talking/thinking balloon icon
func _get_random_ballon_icon(list=false):
	if not list:
		#not from a special list
		var anims = $Balloon/Icon.get_sprite_frames().get_animation_names()
		return anims[rand_range(0,anims.size()-1)]
	else:
		return custom_balloons[int(rand_range(0,custom_balloons.size()))]

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

#check if the teenager is tired enough to go to bed, if so then stop the
#routine and change the state
func check_tiredness():
	var game = get_parent().get_parent()
	
	if is_tired and not is_routine_paused:
		#that means he was sleeping but was interrupted by the player
		#send him back to the bed.
		state_machine.force_state('Sleeping')
		return
	if not is_tired and queue_sleep and not is_routine_paused:
		#now he/she can sleep
		is_tired = true
		state_machine.force_state('Sleeping')
		queue_sleep = false
	
	
	if not is_tired and game.get_time() == sleep_time and not is_routine_paused:
		#time to sleep
		#send him to bed
		remaining_sleep_time = sleep_hours*60
		is_tired = true
		state_machine.force_state('Sleeping')
	elif not is_tired and game.get_time() == sleep_time and is_routine_paused:
		#he needs to sleep but his routine is paused. Wait for him to be free
		#to sleep again
		queue_sleep = true
		
#check if the teen is horny enough to go to the woods with his lover.
func check_love():

	if lover == null or not horny or was_in_love:
		return
	else:
		var lover_ref = weakref(lover)
		if lover_ref.get_ref() == null:
			lover = null
			return 
			
		#check if this isn't a platonic relationship lmao
		if lover.lover != self:
			return
		
	if not is_routine_paused and not state_machine.is_routine_over:
		was_in_love = true
		state_machine.force_state('InLove')

#check if the lighs on the building you are is off
func check_lights():
	var game = get_parent().get_parent()
	if not ((game.time / 60) >= 20 or (game.time / 60) <= 6):
		return
	if checked_light or not is_indoor or game.has_light: return
	
	if state_machine.check_forced_state('CheckingLight'):
		state_machine.force_state('CheckingLight')
		checked_light = true

#check if the teenager needs to go to the bathroom
func check_bowels():
	if not (diarrhea and not was_in_bathroom):
		return
	
	if not is_routine_paused and not state_machine.is_routine_over:
		if state_machine.check_forced_state('Shitting'):
			was_in_bathroom = true
			state_machine.force_state('Shitting')

#check if this teenager is at the same tile that another one.
#when that happens, the teenager with the higher id number should wait
#on the tile while the smaller one moves away.
func check_overlapping_teens():
	var game = get_parent().get_parent()
	
	for teen in game.get_teenagers_alive():
		if teen == self: continue
		if not teen.is_moving: continue
		
		var pos = teen.global_position
		var tile = star.get_closest_tile(pos)
		var s_tile = star.get_closest_tile(global_position)
		
		if tile == s_tile:
			if id > teen.id:
				return false
	
	return true

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
	if add_points: 
		score.set_score(level,int(points))
		#call score animation
		var game = get_parent().get_parent()
		game.ui.play_score_animation(get_global_transform_with_canvas().origin,str(int(value * fear_modifier)))
	
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

func get_traps():
	if traps == []:
		return []
	else:
		return traps
		
func set_speed(value):
	speed = value

func remove_trap(value,free):
	for trap in traps:
		if trap == value:
			if free:
				#trap.queue_free()
				trap.call_deferred('free')
			traps.erase(trap)
			current_trap -= 1 
			break

func set_diarrhea(value):
	diarrhea = value
	
	if not diarrhea:
		was_in_bathroom = false

#enable/disable slow modifier
func set_slow(value):
	slow = value
	
	if slow:
		speed -= base_speed * slow_modifier
	else:
		speed += base_speed * slow_modifier

func set_fast(value):
	fast = value
	
	if fast:
		speed += base_speed * fast_modifier 
	else:
		speed -= base_speed * fast_modifier 
	
#enable/disable horny modifier
func set_horny(value):
	horny = value
	if not horny: was_in_love = false
	
#set a lover (if this teen has one)
func init_lover(path):
	if path != '' and path != null:
		lover = get_node(path)
		return

#check if the ai is moving or not
func set_is_moving(value):
	is_moving = value
	if is_moving:
		if indoor_detection != null: indoor_detection.set_teen_indoor(self)
		if not has_node('MovingTimer'):
			var timer = Timer.new()
			timer.name = 'MovingTimer'
			timer.wait_time = 0.1
			add_child(timer)
			timer.connect("timeout",self,"set_is_moving",[false])
			timer.start()
		else:
			get_node('MovingTimer').stop()
			get_node('MovingTimer').wait_time = 0.1
			get_node('MovingTimer').start()
	else:
		if has_node('MovingTimer'):
			get_node('MovingTimer').stop()

#add fixed traits/temporary effects
func add_traits(traits,permanent=false):
	#LAYOUT: traits[TRAIT][DURATION]
	for trait in traits:
		#don't add duplicated traits
		if self.traits.keys().find(trait) != -1: continue
		
		match trait:
			TRAITS.SLOW:
				self.traits[TRAITS.SLOW] = fast_effect_duration
				set_slow(true)
			TRAITS.HORNY:
				self.traits[TRAITS.HORNY] = slow_effect_duration
				set_horny(true)
			TRAITS.DIARRHEA:
				self.traits[TRAITS.DIARRHEA] = normal_effect_duration
				set_diarrhea(true)
			TRAITS.FAST:
				self.traits[TRAITS.FAST] = fast_effect_duration
				set_fast(true)
			TRAITS.FINAL_GIRL:
				self.traits[TRAITS.FINAL_GIRL] = slow_effect_duration
			_:
				#this teen don't have any traits
				return
				
		if not permanent:
			var effect_timer = preload('res://scenes/CustomTimer.tscn').instance()
			effect_timer.connect('timeout',self,'remove_traits',[[trait],effect_timer])
			add_child(effect_timer)
			effect_timer.stop()
			effect_timer.set_wait_time(self.traits[trait])
			effect_timer.start()
			
#remove traits/effects from a teen
func remove_traits(traits,timer=null):
	if timer != null:
		timer.disconnect('timeout',self,'remove_traits')
		timer.call_deferred ('free')
	
	for trait in traits:
		match trait:
			TRAITS.SLOW:
				set_slow(false)
			TRAITS.HORNY:
				set_horny(false)
			TRAITS.DIARRHEA:
				set_diarrhea(false)
			TRAITS.FAST:
				set_fast(false)
			_:
				print("tried to remove a trait that doesn't exist")
				return
		self.traits.erase(trait)
	
func set_is_indoor(value):
	is_indoor = value
	
	#debug labels
	if is_indoor:
		$Animations/DebugState2.text = "indoor"
	else:
		$Animations/DebugState2.text = "outdoor"

#check if the teen can see an object. Will return false if the object is being
#obstructed by walls.
func is_object_visible(object):
	wall_cast.set_cast_to(object.global_position - wall_cast.global_position)
	wall_cast.force_raycast_update()
	
	if wall_cast.is_colliding():
		return wall_cast.get_collider().name == object.name

func is_teen_visible(teen):
	wall_cast.set_cast_to(teen.global_position - wall_cast.global_position)
	wall_cast.force_raycast_update()
	
	if wall_cast.is_colliding():
		return wall_cast.get_collider().get_parent().name == teen.name
	

#returns the sprite of the current teen's animation-frame.
func get_teen_texture():
	var anim = teenager_anims.get_animation()
	var sprs = teenager_anims.get_sprite_frames()
	var spr_frame = sprs.get_frame(anim,teenager_anims.get_frame())
	
	return spr_frame
	
#returns the sprite of the current teen's dying animation-frame.
func get_dead_teen_texture():
	var anim = $DeadAnimations.get_animation()
	var sprs = $DeadAnimations.get_sprite_frames()
	var spr_frame = sprs.get_frame(anim,$DeadAnimations.get_frame())
	
	return spr_frame

#call other teens into escaping if they are close and can see this 
#teen in panic.
func call_into_escaping():
	var game = get_parent().get_parent()
	var teenagers = game.get_teenagers_alive()
	
	for teen in teenagers:
		if teen == self:continue
		if teen.state_machine.get_current_state() == 'Panic': continue
		if teen.state_machine.get_current_state() == 'Shock': continue
		if teen.state_machine.get_current_state() == 'Screaming': continue
		if teen.state_machine.get_current_state() == 'Cornered': continue
		if teen.state_machine.get_current_state() == 'Escaping': continue
		if teen.state_machine.get_current_state() == 'Escaped': continue
		if teen.state_machine.get_current_state() == 'Crippled': continue
		
		var dis = teen.global_position.distance_to(self.global_position)
		
		if dis < 60:
			if teen.is_object_visible(detection_area):
				teen.state_machine.force_state('Escaping')



