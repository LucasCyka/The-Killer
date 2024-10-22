extends Node2D

"""
	Traps base class.
	All traps will delivery from this class
"""

#TODO: make curiosity modifiers act more at traps? Maybe a trap is too dull
#and the teenager can only fall for it if he has an certain curiosity level.

enum TYPES{
	BUMP,
	LURE,
	MISC,
	VICE,
	NULL
}
var type = TYPES.NULL

var id = 0

#the tileset the trap will lay
var tiles = null
var base = null
var child = null
var ui = null
var oneshot = false setget , is_one_shot
var onspot = false setget , is_on_spot
var walkable = false setget , is_walkable
var trapped_teenagers = []
var price = 0
var is_placed = false setget set_is_placed
var trap_name = null
var trap_desc = null
var death_trap = null
var sound = null

#if the trap is placed in an invalid location this will be true
var is_invalid_tile = false setget set_is_invalid_tile

#if the trap is inside a building or not
var is_indoor = false setget set_is_indoor

#trap modifiers/requirements
var curiosity = 10
var fear = 1
var requirements = []

#constructor
func init(id,base,tiles,child,ui,curiosity,fear,requirements,oneshot,onspot,
price,walkable,_name,desc,death_trap,sound):
	self.curiosity = curiosity
	self.fear = fear
	self.id = id
	self.base = base
	self.tiles = tiles
	self.child = child
	self.ui = ui
	self.requirements = requirements
	self.oneshot = oneshot
	self.onspot = onspot
	self.price = price
	self.walkable = walkable
	self.trap_name = _name
	self.trap_desc = desc
	self.death_trap = death_trap
	self.sound = sound
	
	#replace traps, needs to diconnect this when the trap is placed
	ui.connect("new_trap",self,"exit")
	
	#TODO: change trap modifiers according to their ids.
	
##traps effects - most used by misc and vice traps##
func enter_panic(teenager):
	teenager.state_machine.force_state('Panic')

#add slow trait
func decrease_speed(teenager):
	teenager.add_traits([teenager.TRAITS.SLOW],false)
	#teenager.set_slow(true)

#lmao
func make_horny(teenager):
	teenager.add_traits([teenager.TRAITS.HORNY],false)

func increase_fear():
	pass

func increase_curiosity():
	pass

#lololol
func cause_diarrhea(teenager):
	teenager.add_traits([teenager.TRAITS.DIARRHEA],false)

#put the teenager on the crippled state
func cripple(teenager):
	#check if the teenager can be OnVice state
	if teenager.state_machine.check_forced_state('Crippled'):
		teenager.set_trap(self)
		teenager.state_machine.force_state('Crippled')
		

func activate_vice(teenager):
	#check if the teenager can be OnVice state
	if teenager.state_machine.check_forced_state('OnVice'):
		teenager.state_machine.state_time = 6 #TODO: maybe take this number from the trap?
		teenager.set_trap(self)
		teenager.state_machine.force_state('OnVice')
		
		return true

##
#make the teenager enters on the 'lured state'
func lure_teenager(teenager):
	#check if the teenager can be lured
	if teenager.state_machine.check_forced_state('Lured'):
		if teenager.get_traps().size()> 0:
			#remove any other lure trap
			for lure in teenager.get_traps():
				if lure != child:
					lure.is_used = false
					teenager.remove_trap(lure,true)
		
		teenager.set_trap(self)
		teenager.state_machine.force_state('Lured')
		
		return true

func startle_teenager(teenager,pos):
	if teenager.state_machine.check_forced_state('Startled'):
		teenager.set_trap(self)
		teenager.state_machine.state_position = pos
		teenager.state_machine.force_state('Startled')

#the trap becomes transparent when is in an invalid location
func set_is_invalid_tile(value):
	is_invalid_tile = value
	if is_invalid_tile:
		child.get_node("Texture").set_self_modulate(Color(1,1,1,0.5))
	else: child.get_node("Texture").set_self_modulate(Color(1,1,1,1))
		
func set_is_indoor(value):
	is_indoor = value

func set_is_placed(value):
	is_placed = value
	
	if is_placed:
		if child.name != 'BumpTrap':
			base.audio_system.play_sound('Money')
			#TODO: flying label?

#activate a trap again
func activate_trap(teenager):
	if type == TYPES.VICE:
		child.set_process(true)
		child.is_used = false
		var pos = child.texture.global_position
		
		#check if the trap is close enough to the teenager to be activated
		#right away
		if teenager.kinematic_teenager.global_position.distance_to(pos) < 30:
			if teenager.state_machine.check_forced_state('OnVice'):
				teenager.state_machine.force_state('OnVice')
		else:
			teenager.remove_trap(self,false)
		
	elif type == TYPES.LURE:
		child.is_used = false
		#check if it can be activated right away
		if teenager.state_machine.check_forced_state('Lured'):
			teenager.state_machine.force_state('Lured')
			
			if is_one_shot():
				child.is_used = true
		else:
			#can't be activated again? remove it from the teenager trap list
			#then.
			teenager.remove_trap(self,false)

func is_one_shot():
	return oneshot

func is_on_spot():
	return onspot

func is_walkable():
	return walkable

func deactivate_trap():
	if type == TYPES.VICE:
		child.set_process(false)
		child.is_used = true
	else:
		child.is_used = true

#return true if this trap can be activated by the given teenager
func check_requirements(teenager):
	if requirements[0] == 'NULL':
		return true
		
	#teenager data
	var gender_enum = teenager.GENDER
	var teenager_state = teenager.state_machine.get_current_state()
	
	for requirement in requirements:
		if requirement == 'MEN' and teenager.gender != 'MALE':
			#wrong gender
			return false
		elif requirement == 'WOMEN' and teenager.gender != 'FEMALE':
			#wrong gender
			return false
		elif requirement == 'PANIC' and teenager_state != 'Panic':
			if teenager_state != 'Escaping' and teenager_state != 'Barricading':
				#isn't in panic or escaping/barricading
				return false
		elif requirement == 'MIN10' and teenager.get_curiosity() < 10:
			#not enough curiosity points
			return false
		elif requirement == 'HORNY' and teenager.traits.keys().find(teenager.TRAITS.HORNY) == -1 and teenager.traits.keys().find(teenager.TRAITS.PERVERT) == -1:
			return false
		elif requirement == 'FINALGIRL' and teenager.traits.keys().find(teenager.TRAITS.FINAL_GIRL) != -1:
			return false
		elif requirement == 'NIGHT' and not base.is_night():
			return false
		elif requirement == 'CHICKENPHOBIC' and teenager.traits.keys().find(teenager.TRAITS.CHICKENPHOBIC) == -1:
			return false
		elif requirement == 'GLUTTON' and teenager.traits.keys().find(teenager.TRAITS.GLUTTON) == -1:
			return false
		elif requirement == 'NARCISSISTIC' and teenager.traits.keys().find(teenager.TRAITS.NARCISSISTIC) == -1:
			return false
			
	return true

#return the trap position
func get_trap_position():
	match type:
		TYPES.BUMP:
			return Vector2(0,0)
		_:
			return get_children()[0].global_position

#check if the teenager can see the trap being placed
func is_teenager_seeing_trap():
	var is_seeing = false
	for teen in base.get_teenagers():
		if teen.global_position.distance_to(get_trap_position()) < 100:
			is_seeing = teen.is_object_visible(child.detection_wall)
			
	return is_seeing
	
#destructor
func exit():
	child.queue_free()