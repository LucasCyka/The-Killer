extends Control

"""
	Controls the intro sequence and login for Newgrounds.
"""

#world nodes
onready var info_label = $InfoLabel

var success = false
var current_screen = 0

signal checked_newgrounds

func _ready():
	connect("checked_newgrounds",self,"fade_anim")
	set_process_input(false)
	
	$NewGroundsAPI.App.checkSession()
	var result = yield($NewGroundsAPI, 'ng_request_complete')
	if $NewGroundsAPI.is_ok(result):
		info_label.text = "Success."
		success = true
		print(result.response)
	else:
		print(result.error)
		info_label.text = "Couldn't find Newgrounds user. Your scores and achievements won't be saved. Check if you are logged on Newgrounds and try to refresh the page... \n \n Or press ENTER to continue anyway."
		
	emit_signal("checked_newgrounds")

func _input(event):
	if Input.is_action_just_pressed("Enter") and not success:
		success = true
		fade_anim()

func fade_anim():
	if success:
		$AnimationPlayer.connect("animation_finished",self,"next_screen")
		if current_screen ==0: $AnimationPlayer.play("fade")
	else:
		set_process_input(true)

#go to the next screen
func next_screen(anim):
	current_screen += 1 
	$AnimationPlayer.disconnect("animation_finished",self,"next_screen")
	$AnimationPlayer.play("fade2")
	$LastScreenTimer.connect("timeout",self,"finish_intro")
	$LastScreenTimer.start()

#finish the intro and go to the main menu
func finish_intro():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
