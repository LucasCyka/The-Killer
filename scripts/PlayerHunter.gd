extends Node2D

"""
	Player/hunter. This what the player controlls in the hunter mode
"""

#when the player is removed from the game
signal removed

var base = null
var ui = null
var is_deployed = false setget set_is_deployed
var mouse_position = Vector2(0,0)
var speed = 60

#world nodes
onready var state_machine = $States
onready var kinematic_player = $KinematicPlayer
onready var game = get_parent().get_parent()

#constructor
func init(base,ui):
	self.base = base
	self.ui = ui
	
	ui.connect("element_toggle",self,"_free")

func _process(delta):
	#input info
	mouse_position = get_global_mouse_position()
	
	#debug state
	get_node("KinematicPlayer/StateLabel").text = state_machine.get_current_state()
	if state_machine.get_current_state() == 'Spawning':
		$KinematicPlayer/StateProgress.show()
	else: $KinematicPlayer/StateProgress.hide()
	
func _input(event):
	pass

#move the player to a given location. Returns true when he arrives.
func walk(to):
	#TODO: use A* algorithm for this
	var distance = kinematic_player.global_position.distance_to(to)
	
	if distance > 10:
		var dir = to - kinematic_player.global_position
		dir = dir.normalized()
		kinematic_player.move_and_slide(dir * speed)
		
		return false
	else: 
		return true

#remove the player hunter
func _free():
	game.disable_spawn_points()
	#this signal is used by the 'Game' script to detect when to exit the 
	#hunter mode.
	emit_signal("removed")
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
