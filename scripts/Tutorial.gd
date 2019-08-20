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
onready var infographics = $CanvasLayer/Infographic
onready var player_controller = get_parent().get_node('PlayerController')

var current_step = 0
var current_text = 0
var _step_called = false
var _next_step_key = true

#the teens on game
var teens = []

#text on the textbox
var tutorial_text = {}

var steps = {
	0:{"methods":[funcref(self,'wait')],"params":[3]},
	1:{"methods":[funcref(self,'pause')],"params":[null]},
	2:{"methods":[funcref(self,'show_text')],"params":[true]},
	3:{"methods":[funcref(self,'next_text')],"params":[null]},
	4:{"methods":[funcref(self,'show_text')],"params":[true]},
	5:{"methods":[funcref(self,'next_text')],"params":[null]},
	6:{"methods":[funcref(self,'show_infographic')],"params":['Keys']},
	7:{"methods":[funcref(self,'show_text'),funcref(self,'check_keys')],"params":[false,'Keys']},
	8:{"methods":[funcref(self,'next_text')],"params":[null]},
	9:{"methods":[funcref(self,'hide_infographic')],"params":['Keys']},
	10:{"methods":[funcref(self,'show_infographic')],"params":['Keys2']},
	11:{"methods":[funcref(self,'show_text'),funcref(self,'check_camera_zoom')],"params":[false,Vector2(1,1)]},
	12:{"methods":[funcref(self,'hide_infographic')],"params":['Keys2']},
	13:{"methods":[funcref(self,'next_text')],"params":[null]},
	14:{"methods":[funcref(self,'show_text')],"params":[true]},
	15:{"methods":[funcref(self,'move_camera')],"params":[Vector2(621,100)]},
	16:{"methods":[funcref(self,'next_text')],"params":[null]},
	17:{"methods":[funcref(self,'show_text')],"params":[true]},
	18:{"methods":[funcref(self,'show_infographic')],"params":['HighLight']},
	19:{"methods":[funcref(self,'next_text')],"params":[null]},
	20:{"methods":[funcref(self,'show_text')],"params":[true]},
	21:{"methods":[funcref(self,'next_text')],"params":[null]},
	22:{"methods":[funcref(self,'show_text')],"params":[true]},
	23:{"methods":[funcref(self,'hide_infographic')],"params":['HighLight']},
	24:{"methods":[funcref(self,'highlight_teen')],"params":['Teenager2']},
	25:{"methods":[funcref(self,'resume')],"params":[null]},
	26:{"methods":[funcref(self,'next_text')],"params":[null]},
	27:{"methods":[funcref(self,'show_text'),funcref(self,'check_teen_panel')],"params":[false,'Teenager2']},
	28:{"methods":[funcref(self,'remove_teen_highlight')],"params":['Teenager2']},
	29:{"methods":[funcref(self,'next_text')],"params":[null]},
	30:{"methods":[funcref(self,'show_text')],"params":[true]},
	31:{"methods":[funcref(self,'next_text')],"params":[null]},
	32:{"methods":[funcref(self,'show_text')],"params":[true]},
	33:{"methods":[funcref(self,'next_text')],"params":[null]},
	34:{"methods":[funcref(self,'show_text')],"params":[true]},
	35:{"methods":[funcref(self,'next_text')],"params":[null]},
	36:{"methods":[funcref(self,'show_text')],"params":[true]},
}

#init tutotiral
func _ready():
	#load tutorial text
	var file = File.new()
	file.open("res://resources/json/tutorial_text.json",File.READ)
	var data = file.get_as_text()
	tutorial_text = parse_json(data)
	
	connect('next_step',self,'next_step')
	
	for teen in get_tree().get_nodes_in_group('AI'):
		teens.append(teen)

#execute the current function of the current step
func _process(delta):
	if not _step_called:
		for method in range(steps[current_step]['methods'].size()):
			#the curret step wasn't called, call it now.
			if steps[current_step]['params'][method] != null:
				_step_called = true
				steps[current_step]['methods'][method].call_func(steps[current_step]['params'][method])
			else:
				_step_called = true
				steps[current_step]['methods'][method].call_func()
	
#user input
func _input(event):
	if event.is_action_pressed("Enter"):
		if text_box.is_visible() and text.get_visible_characters()>1:
			show_text(_next_step_key,true,true)

#show the current text at the text box
func show_text(next_step=true,_timer = false,foward = false):
	#TODO: lower sounds, music etc...
	if not _timer:
		text_box.show()
		text.set_text(tutorial_text['Text'][str(current_text)])
		text.set_visible_characters(0)
		timer.wait_time = text_speed
		timer.connect('timeout',self,'show_text',[next_step,true])
		_next_step_key = next_step
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
			if next_step:
				emit_signal("next_step")
			
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
	get_tree().paused = true
	emit_signal("next_step")

#resume game
func resume():
	get_tree().paused = false
	emit_signal("next_step")

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

#show animations from the tutorial
func show_infographic(spr,pos=null):
	infographics.get_node(spr).show()
	emit_signal("next_step")

func hide_infographic(spr):
	infographics.get_node(spr).hide()
	emit_signal("next_step")

#hight a given teen
func highlight_teen(teen_name):
	for teen in teens:
		if teen.name == teen_name:
			var highlight = $CanvasLayer/Infographic/HighLight2.duplicate()
			teen.add_child(highlight)
			highlight.show()
			
			#var teen_pos = teen.get_global_transform_with_canvas()
			#teen_pos = teen_pos.origin
			
			#$CanvasLayer/Infographic/HighLight2.show()
			#$CanvasLayer/Infographic/HighLight2.global_position = teen_pos
			break
	emit_signal("next_step")

func remove_teen_highlight(teen_name):
	for teen in teens:
		if teen.name == teen_name:
			teen.get_node('HighLight2').call_deferred('free')
			break
	emit_signal("next_step")

#check if all the given keys are pressed before going to the next step.
#also change their textures when pressed.
func check_keys(keys,_signal = null):
	if _signal == null:
		for key in infographics.get_node(keys).get_children():
			if key is TextureButton:
				key.connect('pressed',self,'check_keys',[keys,key])
	else:
		var btn = _signal
		btn.disconnect('pressed',self,'check_keys')
		btn.texture_normal = btn.texture_pressed
		btn.disabled = true
		
		#check if he pressed enough buttons
		var pressed_btns = 0
		for key in infographics.get_node(keys).get_children():
			if key is TextureButton:
				if key.disabled:
					pressed_btns += 1
		
		if keys == 'Keys' and pressed_btns >=4:
			#pressed enough buttons here, next step
			if text_box.is_visible():
				show_text(_next_step_key,true,true)
				text_box.hide()
				emit_signal("next_step")
				timer.disconnect('timeout',self,'show_text')
			else:
				emit_signal("next_step")

#check if the camera's zoom level is different from 'zoom'
func check_camera_zoom(zoom,_signal = false):
	if not _signal:
		player_controller.connect("changed_zoom",self,"check_camera_zoom",[zoom,true])
	else:
		if player_controller.camera.get_zoom() != zoom:
			player_controller.disconnect("changed_zoom",self,"check_camera_zoom")
			if text_box.is_visible():
				show_text(_next_step_key,true,true)
				text_box.hide()
				emit_signal("next_step")
				if timer.is_connected('timeout',self,'show_text'):
					timer.disconnect('timeout',self,'show_text')
			else:
				emit_signal("next_step")
			
			#emit_signal("next_step")
			
#move the camera to a given position
func move_camera(to,_signal = false):
	#reset zooms
	player_controller.camera.set_zoom(Vector2(1,1))
	if not _signal:
		player_controller.travel_camera_to(to)
		player_controller.connect("travel_finished",self,"move_camera",[to,true])
	else:
		player_controller.disconnect("travel_finished",self,"move_camera")
		emit_signal("next_step")

#go to the next step when a given teen panel is open
func check_teen_panel(teen_name,_signal = false,btn = null):
	if not _signal:
		for teen in teens:
			if teen.name == teen_name:
				var b = teen.get_node('TeenagerButton')
				b.connect('pressed',self,'check_teen_panel',[teen_name,true,b])
				
				break
	else:
		btn.disconnect('pressed',self,'check_teen_panel')
		emit_signal("next_step")
			
			
	







