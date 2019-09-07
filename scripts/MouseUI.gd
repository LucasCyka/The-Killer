extends Control

"""
	Manage mouse icons according to several states on the game.
"""

var base = null
var tree = null

onready var mouse = $MouseAnims

#cursors and their priorities
var cursors = {
	'DEFAULT':-1,
	'LIGHTCUT':0,
	'BUMP':1,
	'TRAP':2,
	'MACHETE':3
}

#the cursors that can be showed at the moment
var cursor_events = [-1]

var game = null

#initialize
func init(base):
	self.base = base
	self.game = base.game
	self.tree = get_tree()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	### connect all events that will change the mouse cursor ###
	for teenager_btn in base.get_teenagers_buttons():
		teenager_btn.connect("mouse_entered",self,"set_events",['MACHETE',false])
		teenager_btn.connect("mouse_exited",self,"set_events",['MACHETE',true])
	
	for object in game.get_world_objects():
		if object.cursor != '':
			object.get_node('Button').connect('mouse_entered',self,'set_events',[object.cursor,false])
			object.get_node('Button').connect('mouse_exited',self,'set_events',[object.cursor,true])
	
		
#move the "fake" mouse
func _process(delta):
	mouse.global_position = get_global_mouse_position()
	
	#play the cursor animation that has the highest priority
	var max_anim = null
	for key in cursors.keys():
		if cursors[key] == cursor_events.max():
			max_anim = key
			break
	
	if mouse.get_animation() != max_anim:
		mouse.play(max_anim)
	
	if is_placing_traps() and cursor_events.find(cursors['TRAP']) == -1:
		set_events('TRAP',false)
	elif not is_placing_traps() and cursor_events.find(cursors['TRAP']) != -1:
		set_events('TRAP',true)

	
func set_events(event,remove):
	var mode = game.get_current_mode()
	
	match event:
		'MACHETE':
			if not remove and mode == game.MODE.HUNTING: cursor_events.append(cursors[event])
			else: cursor_events.erase(cursors[event])
		'TRAP':
			if not remove: cursor_events.append(cursors[event])
			else: cursor_events.erase(cursors[event])
		'LIGHTCUT':
			if not remove: cursor_events.append(cursors[event])
			else: cursor_events.erase(cursors[event])
		'BUMP':
			if not remove: cursor_events.append(cursors[event])
			else: cursor_events.erase(cursors[event])

func is_placing_traps():
	var traps = tree.get_nodes_in_group('Bump') + tree.get_nodes_in_group('Vice')
	traps = traps + tree.get_nodes_in_group('Misc') + tree.get_nodes_in_group('Lure')
	
	if traps == []: return false
	
	for trap in traps:
		if not trap.is_placed: return true
	
	return false






