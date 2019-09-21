extends Node2D

"""
	Controls the main menu and intro of the game.
"""

func _ready():
	if settings.first_time:
		$StartLabel.show()
		$MenuPanel.hide()
		settings.first_time = false
	else:
		set_process_input(false)
		start_anim()
		start_music()

func _input(event):
	if Input.is_action_just_pressed("Enter"):
		$StartLabel.hide()
		set_process_input(false)
		$Audio.play_sound('Panic2')
		start_timer()
		
func start_anim():
	$BackgroundAnimation/AnimationPlayer.play("New Anim")
	
func start_music():
	$Audio.play_music('Menu')

#first time timer
func start_timer():
	var timer = Timer.new()
	
	timer.wait_time = 2
	timer.one_shot = true
	add_child(timer)
	timer.stop()
	timer.connect('timeout',self,'start_anim')
	timer.connect('timeout',self,'start_music')
	timer.start()
	
	var timer2 = Timer.new()
	timer2.wait_time = 7
	timer2.one_shot = true
	add_child(timer2)
	timer2.stop()
	timer2.connect('timeout',self,'show_menu')
	timer2.start()
	
func show_menu():
	$MenuPanel.show()
	
	print('show panel')
	
	
	


