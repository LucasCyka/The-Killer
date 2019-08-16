extends Node2D

"""
	Control the tutorial in the first level
"""

signal next_step

const text_speed = 0.05

#world nodes
onready var text_box = $CanvasLayer/TextBox
onready var text_animation = $CanvasLayer/TextBox/Animation
onready var text = $CanvasLayer/TextBox/Label
onready var timer = $CanvasLayer/TutorialTimer

var current_step = 0
var current_text = 0
var _step_called = false

#text on the textbox
var tutorial_text = {}

var steps = {
	0:{"method":funcref(self,'wait'),"param":3},
	1:{"method":funcref(self,'show_text'),"param":true},
	2:{"method":funcref(self,'next_text'),"param":null},
	3:{"method":funcref(self,'show_text'),"param":true}
}

#init tutotiral
func _ready():
	#load tutorial text
	var file = File.new()
	file.open("res://resources/json/tutorial_text.json",File.READ)
	var data = file.get_as_text()
	tutorial_text = parse_json(data)
	
	connect('next_step',self,'next_step')

#execute the current function of the current step
func _process(delta):
	if not _step_called:
		#the curret step wasn't called, call it now.
		if steps[current_step]['param'] != null:
			_step_called = true
			steps[current_step]['method'].call_func(steps[current_step]['param'])
		else:
			_step_called = true
			steps[current_step]['method'].call_func()
	
#user input
func _input(event):
	if event.is_action_pressed("Enter"):
		if text_box.is_visible() and text.get_visible_characters()>1:
			show_text(true,true,true)

#show the current text at the text box
func show_text(lower_sounds=true,_timer = false,foward = false):
	#TODO: lower sounds, music etc...
	if not _timer:
		text_box.show()
		text.set_text(tutorial_text['Text'][str(current_text)])
		text.set_visible_characters(0)
		timer.wait_time = text_speed
		timer.connect('timeout',self,'show_text',[lower_sounds,true])
		timer.start()
	elif foward:
		#fast foward the text
		if text.get_visible_characters() != text.get_total_character_count():
			text.set_visible_characters(text.get_total_character_count()-1)
			text_animation.play('neutral')
		else:
			timer.disconnect('timeout',self,'show_text')
			text_box.hide()
			text.set_visible_characters(0)
			emit_signal("next_step")
			#print('next')
			
	else:
		timer.stop()
		text.set_visible_characters(text.get_visible_characters()+1)
		if text.get_visible_characters() == text.get_total_character_count():
			text_animation.play('neutral')
		else:
			if text_animation.get_animation() != 'talking':
				text_animation.play('talking')
			timer.start()

#pause game
func pause():
	pass

#resume game
func resume():
	pass

#advance the tutorial foward
func next_step():
	current_step += 1
	_step_called = false

#advance on the next text
func next_text():
	current_text += 1
	emit_signal("next_step")

func previous_text():
	current_text -= 1

#wait a given amount of time before going to the next step
func wait(time,_signal = false):
	if not _signal:
		timer.wait_time = time
		timer.connect('timeout',self,'wait',[time,true])
		timer.start()
	else:
		timer.disconnect('timeout',self,'wait')
		emit_signal("next_step")










