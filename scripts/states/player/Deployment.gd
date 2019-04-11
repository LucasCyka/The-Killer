extends Node

"""
	Player deployment state
"""

signal finished

var base
var mouse_position
var spawn_points
var is_on_spawn = false

#constructor
func init(base,state_position,state_time):
	self.base = base
	set_process_input(true)
	self.base.player.is_deployed = false

func update(delta):
	if base == null:
		return
	
	if spawn_points == null:
		spawn_points = self.base.player.game.enable_spawn_points()
		return
	
	mouse_position = base.player.mouse_position
	
	#create a 'magnetic effect' when the hunter is near spawn points
	for point in spawn_points:
		is_on_spawn = false
		if point.distance_to(mouse_position) < 50:
			base.player.kinematic_player.global_position = Vector2(point.x+10,point.y+10)
			is_on_spawn = true
			break
	
	if not is_on_spawn:
		#move the player around the map if he's not close to any spawn point
		base.player.kinematic_player.global_position = mouse_position

#spawn mode or free the hunter
func input(event):
	if Input.is_action_just_pressed("ok_input"):
		if is_on_spawn and check_teenagers():
			transitions()
			exit()
	elif Input.is_action_just_pressed("cancel_input"):
		base.player._free()

#returns true if any teenager is in panic, escaping or any state that 
#allows the hunter to be spawned
func check_teenagers():
	var teenagers = get_tree().get_nodes_in_group("AI")
	var dead_teen = []
	
	for teen in teenagers:
		var state = teen.state_machine.get_current_state()
		
		match state:
			'Panic':
				return true
			'Escaping':
				return true
			'Crippled':
				return true
			'Shock':
				return true
			'Fighting':
				return true
			'Screaming':
				return true
			'Dead':
				dead_teen.append(teen)
				
	if dead_teen.size() == teenagers.size()-1:
		#when there's only one teenager left, the player can 
		#whenever he wants
		
		return true
	
	return false
	

#detect transitiosn between states
func transitions():
	### DEPLOYMENT TO SPAWNING ###
	base.state_time = 2 #time to spawn
	base.stack.append(base.get_node("Spawning"))

#destructor
func exit():
	set_process_input(false)
	emit_signal("finished")