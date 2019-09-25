extends Node2D

"""
	Controls the main menu and intro of the game.
"""

onready var mouse = $Mouse

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#newgrounds_test()
	if settings.first_time:
		$StartLabel.show()
		$OptionsMenu.hide()
		settings.first_time = false
	else:
		set_process_input(false)
		start_anim()
		start_music()
		$StartLabel.hide()
	
	$BackgroundAnimation/VERSION.text = settings.version
	

func _input(event):
	if Input.is_action_just_pressed("Enter"):
		$StartLabel.hide()
		set_process_input(false)
		$Audio.play_sound('Panic2')
		start_timer()

func _process(delta):
	if not $BackgroundAnimation.is_visible(): 
		mouse.hide()
		return
	else:
		mouse.show()
		
	mouse.global_position = get_global_mouse_position()

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
	$OptionsMenu.show()
	
	print('show panel')
	
func newgrounds_test():
	"""
	$NewGroundsAPI.Gateway.getDatetime()
	var result = yield($NewGroundsAPI, 'ng_request_complete')
	if $NewGroundsAPI.is_ok(result):
		print('Datetime: ' + str(result.response.datetime))
	else:
		print('Error: ' + result.error)
	"""
	$NewGroundsAPI.App.checkSession()
	var result = yield($NewGroundsAPI, 'ng_request_complete')
	if $NewGroundsAPI.is_ok(result):
		print('Session: ' + str(result.response))
	else:
		print('Error: ' + result.error)
	


