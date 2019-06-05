extends Node

"""
	Custom timer node with a few changes for AI uses.
	The speed of the the timer will be dictate by normal timers. 
"""

signal timeout

var wait_time = 0 setget set_wait_time, get_wait_time
var one_shot = false setget set_one_shot, is_one_shot
var time_left = 0 setget _set_time_left, get_time_left
var stop = true setget, is_stopped

onready var game = get_tree().get_root().get_node('Main')

#intialize
func _ready():
	#timers speed
	$NormalSpeed.set_wait_time(game.default_speed)
	$FastSpeed.set_wait_time(game.fast_speed)
	$UltraSpeed.set_wait_time(game.ultra_speed)
	$DebugSpeed.set_wait_time(game.debug_speed)
	
	#connect signals and start the timers
	for timer in get_children():
		timer.connect("timeout",self,"_timer_finished",[timer])
		timer.start()

func start():
	_set_time_left(wait_time)
	stop = false
	
func stop():
	stop = true

func is_stopped():
	return stop

func set_wait_time(value):
	wait_time = value
	
func get_wait_time():
	return wait_time
	
func _set_time_left(value):
	time_left = value

func get_time_left():
	return time_left

func set_one_shot(value):
	one_shot = value

func is_one_shot():
	return one_shot

#update time_left for the current speed
func _timer_finished(timer):
	if not is_stopped():
		if common.is_float_equal(game.timer_speed,timer.wait_time):
			_set_time_left(get_time_left()-1)
			if get_time_left() <= 0:
				if is_one_shot():
					stop = true
				else:
					start()
				emit_signal("timeout")
				
		