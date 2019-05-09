extends Timer

"""
	Controls the timers are used by the teen.
"""

enum MODE{
	DEFAULT = 1,
	FAST = 2,
	ULTRA_FAST = 3,
	DEBUG = 4
}

var current_mode = MODE.DEFAULT
var wait = 0
onready var game = get_tree().get_root().get_node('Main')

func _ready():
	wait = wait_time

#detect transitions between each mode and change the speed
func _process(delta):
	if game == null:
		return
	
	if current_mode != game.ai_timer_speed and not is_stopped():
		self.set_wait_time(get_wait_time())
	
#overried function
func set_wait_time(value):
	stop()
	var spd = game.ai_timer_speed
	current_mode = spd
	wait_time = float(value) / float(spd)
	start()


















