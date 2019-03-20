extends Node2D

"""
	Player/hunter. This what the player controlls in the hunter mode
"""

var base = null
var ui = null
var _selected_teenager = null
var target = null
var is_deployed = false setget set_is_deployed
var mouse_position = Vector2(0,0)
var speed = 60
var exiting = false
var current_path = []
var current_target = Vector2(0,0)

#world nodes
onready var state_machine = $States
onready var kinematic_player = $KinematicPlayer
onready var game = get_parent().get_parent()

#constructor
func init(base,ui):
	self.base = base
	self.ui = ui
	
	ui.connect("element_toggle",self,"_free")
	#teenager signals. Used to target teenagers
	for teenager in base.get_teenagers():
		var _btn = teenager.get_node("KinematicTeenager/TeenagerButton")
		_btn.connect("mouse_entered",self,"select_target",[teenager])
		_btn.connect("mouse_exited",self,"select_target",[null])

func _process(delta):
	#input info
	mouse_position = get_global_mouse_position()
	
	#debug state
	get_node("KinematicPlayer/StateLabel").text = state_machine.get_current_state()
	if state_machine.get_current_state() == 'Spawning':
		$KinematicPlayer/StateProgress.show()
	else: $KinematicPlayer/StateProgress.hide()
	

#click on teenagers to attack them
func _input(event):
	if Input.is_action_just_pressed("cancel_input"):
		target = _selected_teenager
		
		
		if state_machine.get_current_state() != 'Spawning' and state_machine.get_current_state() != 'Deployment':
			#exit the hunter mode when the player hits 'escape'
			if Input.is_key_pressed(KEY_ESCAPE):
				#TODO: confirm if the player really wants to exit
				_free()
	elif Input.is_action_just_pressed("ok_input"):
		target = null

#move the player to a given location. Returns true when he arrives.
func walk(to):
	#TODO: this is very spaghetti, I need to fix it later.
	var distance = kinematic_player.global_position.distance_to(to)
	
	if distance > 10:
		var path = current_path
		#find a path to the location if dindn't found already
		if current_path == []:
			path = star.find_path(kinematic_player.global_position,to)
			current_path = path
			current_target = to
		else:
			if current_target != to:
				path = star.find_path(kinematic_player.global_position,to)
				current_path = path
		
		var dir = Vector2(0,0)
		if path.size() == 0:
			current_path = []
			return true
		elif path.size() < 2:
			current_path = []
			return true
		else:
			if path[1].distance_to(kinematic_player.global_position) <2:
				path.remove(1)
				return false
				
		dir = path[1] - kinematic_player.global_position	
		dir = dir.normalized()
		kinematic_player.move_and_slide(dir * speed)
		
		return false
	else: 
		current_path = []
		return true

#start to attack the teenager
func attack(teenager):
	#TODO: check if the teenager is fighting before killig him
	#TODO: check if he's not dead already
	teenager.state_machine.force_state("Dead")

#remove the player hunter
func _free():
	game.disable_spawn_points()
	exiting = true
	#this signal is used by the 'Game' script to detect when to exit the 
	#hunter mode.
	base.set_current_mode(base.MODE.PLANNING)
	queue_free()
	
func set_is_deployed(value):
	is_deployed = value
	
	#so the player isn't removed if he clicks on every element on the ui
	if !is_deployed == false:
		if ui.is_connected("element_toggle",self,"_free"):
			ui.disconnect("element_toggle",self,"_free")
	else:
		if !ui.is_connected("element_toggle",self,"_free"):
			ui.connect("element_toggle",self,"_free")
			
#the teenager target this player selected with right click
func select_target(target):
	_selected_teenager = target