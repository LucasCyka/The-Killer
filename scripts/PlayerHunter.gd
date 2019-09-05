extends KinematicBody2D

"""
	Player/hunter. This what the player controlls in the hunter mode
"""

#interval (in seconds) that the player will take to decrease health points
#from a door
const door_attacking_interval = 1

var id = 0
var attacking_animation_id = 0
var base = null
var ui = null
var _selected_teenager = null
var target = null
var is_deployed = false setget set_is_deployed
var is_indoor = false setget set_is_indoor
var is_attacking = false
var current_attacking_id = -1
var mouse_position = Vector2(0,0)
var speed = 50
var exiting = false
var current_path = []
var teenager_on_sight = []
var current_target = Vector2(0,0)
var facing_direction = Vector2(0,1)
var door_collision = Vector2(0,0)
var indoor_detection = null
var tiredness = 0
var attacking_door = false setget set_attacking_door
var attacking_door_modifier = 10 #TODO: this should be in an array if I want more player's characters

#world nodes
onready var state_machine = $States
onready var kinematic_player = self
onready var player_anims = $PlayerAnims
onready var game = get_parent().get_parent()
onready var sight_area = $SightArea
onready var wall_cast = $SightArea/WallCast
onready var tiredness_bar = $Tiredness

#some attacking animations have sound effects attrached to it,
#their sound(s) and the time that they must be played is stored in this
#dictionary.
#layout ID:[frames],[sounds]
var animations_sound_data = {
	1:[[2,5],['PlayerSlash','Blood']]
}

#dictionary containing all the animations
#layout ID:STATE-DIR
var animations_data = {
	"Idle":{
		Vector2(0,1):{"anim":str(id) + ":Idle-Down","flip":false},
		Vector2(0,-1):{"anim":str(id) + ":Idle-Up","flip":false},
		Vector2(1,0):{"anim":str(id) + ":Idle-Side","flip":false},
		Vector2(-1,0):{"anim":str(id) + ":Idle-Side","flip":true}},
	
	"Moving":{
		Vector2(0,1):{"anim":str(id) + ":Moving-Down","flip":false},
		Vector2(0,-1):{"anim":str(id) + ":Moving-Up","flip":false},
		Vector2(1,0):{"anim":str(id) + ":Moving-Side","flip":false},
		Vector2(-1,0):{"anim":str(id) + ":Moving-Side","flip":true}},
	
	"Attacking":{
		Vector2(0,1):{"anim":str(id) + ":Attacking-Down","flip":false},
		Vector2(0,-1):{"anim":str(id) + ":Attacking-Up","flip":false},
		Vector2(1,0):{"anim":str(id) + ":Attacking-Side","flip":false},
		Vector2(-1,0):{"anim":str(id) + ":Attacking-Side","flip":true}},
		
	"Deployment":{
		Vector2(0,1):{"anim":str(id) + ":Idle-Down","flip":false},
		Vector2(0,-1):{"anim":str(id) + ":Idle-Up","flip":false},
		Vector2(1,0):{"anim":str(id) + ":Idle-Side","flip":false},
		Vector2(-1,0):{"anim":str(id) + ":Idle-Side","flip":true}},
		
	"EndingSpawn":{
		Vector2(0,1):{"anim":str(id) + ":Moving-Down","flip":false},
		Vector2(0,-1):{"anim":str(id) + ":Moving-Up","flip":false},
		Vector2(1,0):{"anim":str(id) + ":Moving-Side","flip":false},
		Vector2(-1,0):{"anim":str(id) + ":Moving-Side","flip":true}}
	
}

#constructor
func init(base,ui):
	self.base = base
	self.ui = ui
	set_tiredness()
	#TODO: set ID
	
	ui.connect("element_toggle",self,"_free")
	#teenager signals. Used to target teenagers
	for teenager in base.get_teenagers():
		var _btn = teenager.get_node("TeenagerButton")
		_btn.connect("mouse_entered",self,"select_target",[teenager])
		_btn.connect("mouse_exited",self,"select_target",[null])
	
func _process(delta):
	#input info
	mouse_position = get_global_mouse_position()
	
	#check if the teenager can see the player
	if teenager_on_sight.size() != 0:
		check_teenager_sight()
	
	#debug state
	get_node("StateLabel").text = state_machine.get_current_state()
	if state_machine.get_current_state() == 'Spawning':
		$StateProgress.show()
	else: $StateProgress.hide()
	
	update_animations()
	play_attacking_sound()
	set_indoor_detection()
	
#click on teenagers to attack them
func _input(event):
	if Input.is_action_just_pressed("cancel_input"):
		if is_attacking:
			#prevent the player from exiting hunting mode if he's
			#attacking
			return
		
		target = _selected_teenager
		
		if state_machine.get_current_state() != 'Spawning' and state_machine.get_current_state() != 'Deployment' and state_machine.get_current_state() != 'EndingSpawn':
			#exit the hunter mode when the player hits 'escape'
			if Input.is_key_pressed(KEY_ESCAPE):
				#TODO: confirm if the player really wants to exit
				_free()
	elif Input.is_action_just_pressed("ok_input"):
		target = null

#move the player to a given location. Returns true when he arrives.
func walk(to):
	#TODO: this is very spaghetti, I need to fix it later.
	var distance = kinematic_player.global_position.distance_to(to)
	
	if distance > 10:
		var path = current_path
		#find a path to the location if dindn't found already
		if current_path == []:
			path = star.find_path(kinematic_player.global_position,to)
			current_path = path
			current_target = to
		else:
			if current_target != to:
				path = star.find_path(kinematic_player.global_position,to)
				current_path = path
		
		var dir = Vector2(0,0)
		if path.size() == 0:
			current_path = []
			return true
		elif path.size() < 2:
			current_path = []
			return true
		else:
			if path[1].distance_to(kinematic_player.global_position) <2:
				path.remove(1)
				return false
				
		dir = path[1] - kinematic_player.global_position	
		dir = dir.normalized()
		
		#door collisions
		dir.y += int(door_collision.y > 0 and dir.y < 0)
		dir.y -= int(door_collision.y < 0 and dir.y > 0)
		dir.x -= int(door_collision.x > 0 and dir.x > 0)
		dir.x += int(door_collision.x < 0 and dir.x < 0)
		
		var door_dir = dir.round()
		
		if door_dir.x == -0: door_dir.x = 0
		elif door_dir.y == -0: door_dir.y = 0
		
		if door_dir.x ==0 and door_dir.y ==0:
			return false
		#end door collisions
		
		kinematic_player.move_and_slide(dir * speed)
		
		#get the direction the hunter is facing
		facing_direction = dir.round()
		#for some reason godot is returning '-0' sometimes... why?
		if facing_direction.x == -0: facing_direction.x = 0
		elif facing_direction.y == -0: facing_direction.y = 0
		
		#prevent the player from trying walk in diagonals
		if abs(facing_direction.x) == abs(facing_direction.y):
			if abs(dir.x) > abs(dir.y):
				facing_direction.y = 0
			else: facing_direction.x = 0
		
		return false
	else: 
		current_path = []
		return true

#start to attack the teenager
func attack(teenager):
	#TODO: check if the teenager is fighting before killig him
	#TODO: check if he's not dead already
	if not teenager.is_immune:
		teenager.state_machine.force_state("Dead")
		current_attacking_id = 0

func attack_door(door):
	var door_ref = weakref(door)
	if door_ref.get_ref() == null: 
		set_attacking_door(false)
		return
	door.set_door_health(door.get_door_health()-attacking_door_modifier)

#remove the player hunter
func _free():
	game.disable_spawn_points()
	exiting = true
	#this signal is used by the 'Game' script to detect when to exit the 
	#hunter mode.
	if base.get_current_mode() != base.MODE.WON:
		base.set_current_mode(base.MODE.PLANNING)
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
			
#this will tell if the player is inside a building or not
func set_is_indoor(value):
	is_indoor = value
	
	if is_indoor:
		$IndoorLabel.text = "Indoor"
	else:
		$IndoorLabel.text = "Outdoor"

#check if the player is indoor or outdoor
func set_indoor_detection():
	if indoor_detection == null: indoor_detection = game.get_indoor_detection()
	
	indoor_detection.set_player_indoor(self)

#the tiredness will affect the time the player needs before spawning
func set_tiredness():
	tiredness = base.player_tiredness
	tiredness_bar = $Tiredness
	tiredness_bar.set_min(0)
	tiredness_bar.set_max(base.max_tiredness)
	tiredness_bar.set_value(tiredness)

#start/stop door attacks
func set_attacking_door(value):
	attacking_door = value
	
	if attacking_door:
		if not has_node("DoorTimer"):
			var door = null
			var doors = game.get_doors()
			
			for _door in doors:
				if _door.current_player == self:
					door = _door
					break
			if door == null: 
				print('set_attacking_door() couldnt find any doors!')
				return
			
			var door_timer = preload('res://scenes/CustomTimer.tscn').instance()
			add_child(door_timer)
			door_timer.stop()
			door_timer.name = 'DoorTimer'
			door_timer.connect('timeout',self,'attack_door',[door])
			door_timer.start()
		pass
	else:
		if has_node("DoorTimer"):
			get_node("DoorTimer").queue_free()
			pass
	

#the teenager target this player selected with right click
func select_target(target):
	_selected_teenager = target
	
#check if the teenager can see the player hunter
func check_teenager_sight():
	if not is_deployed or state_machine.get_current_state() == 'Deployment':
		return
		
	for teen in teenager_on_sight:
		var teen_pos = teen.global_position.normalized()
		var player_pos = kinematic_player.global_position.normalized()
		var distance = teen.global_position.distance_to(kinematic_player.global_position)
		var dir = teen_pos - player_pos
		var behind_wall = false
		
		if teen.is_immune:
			continue
		
		#raycast to ensure that the teen can really see him
		wall_cast.set_cast_to(teen.global_position - wall_cast.global_position)
		wall_cast.force_raycast_update()
		if wall_cast.is_colliding():
			if wall_cast.get_collider().name != 'DetectionArea':
				#the teen is behind a wall and can't see the player
				behind_wall = true
		
		#check if he didn't see the player before
		if not teen.saw_player and not behind_wall:
			var facing = dir.dot(teen.facing_direction)
			if distance < 100 and is_indoor == teen.is_indoor:
				#he's close enough to be in panic or in shock
				teen.state_machine.force_state('Panic')
				teen.saw_player = true
				teenager_on_sight.erase(teen)
			else:
				if floor(facing) == -1 and is_indoor == teen.is_indoor:
					#he's not so close to the player, but he is facing the same direction
					teen.state_machine.force_state('Panic')
					teen.saw_player = true
					teenager_on_sight.erase(teen)

#check if the teenager entered the player sight area
func on_sight_area(area):
	if area.name == 'DetectionArea':
		if teenager_on_sight.find(area.get_parent()) == -1:
			teenager_on_sight.append(area.get_parent())
			#body.get_parent().saw_player = false

#check if teenager left the player sight area
func out_sight_area(area):
	if area.name == 'DetectionArea':
		if teenager_on_sight.find(area.get_parent()) != -1:
			teenager_on_sight.remove(teenager_on_sight.find(area.get_parent()))

func get_position():
	return kinematic_player.global_position

#update the player animations according to its id
func update_animations():
	var state = state_machine.get_current_state()
	
	if state != 'Attacking':
		if animations_data.keys().find(state) == -1:
			#push_warning('No animations found for this state')
			return
		
		player_anims.play(animations_data[state][facing_direction]['anim'])
		player_anims.set_flip_h(animations_data[state][facing_direction]['flip'])
		
	else:
		pass
		#attacking animations work a bit different than the others

#play sounds during attacking animations
func play_attacking_sound():
	if is_attacking and current_attacking_id != -1:
		#1:[[2,5],['PlayerSlash','Blood']]
		
		if animations_sound_data[1][0].size() == current_attacking_id:
			#no more sounds to be played for this attacking animation
			is_attacking = false
			current_attacking_id = -1
			return
		
		if player_anims.get_frame() == animations_sound_data[1][0][current_attacking_id]:
			game.audio_system.play_2d_sound(animations_sound_data[1][1][current_attacking_id],global_position)
			
			current_attacking_id += 1





