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

func _input(event):
	#remove the player on deployment mode
	if Input.is_action_just_pressed("cancel_input") and !is_deployed:
		_free()

#remove the player hunter
func _free():
	emit_signal("removed")
	queue_free()
	
func set_is_deployed(value):
	is_deployed = value
	
	#so the player isn't removed if he clicks on every element on the ui
	if is_deployed == false:
		pass