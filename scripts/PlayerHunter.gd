extends Node2D

"""
	Player/hunter. This what the player controlls in the hunter mode
"""

var base = null
var ui = null
var _selected_teenager = null
var target = null
var is_deployed = false setget set_is_deployed
var is_indoor = false setget set_is_indoor
var mouse_position = Vector2(0,0)
var speed = 60
var exiting = false
var current_path = []
var teenager_on_sight = []
var current_target = Vector2(0,0)

#world nodes
onready var state_machine = $States
onready var kinematic_player = $KinematicPlayer
onready var game = get_parent().get_parent()
onready var sight_area = $KinematicPlayer/SightArea
onready var wall_cast = $KinematicPlayer/SightArea/WallCast

#constructor
func init(base,ui):
	self.base = base
	self.ui = ui
	
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
	get_node("KinematicPlayer/StateLabel").text = state_machine.get_current_state()
	if state_machine.get_current_state() == 'Spawning':
		$KinematicPlayer/StateProgress.show()
	else: $KinematicPlayer/StateProgress.hide()
	
#click on teenagers to attack them
func _input(event):
	if Input.is_action_just_pressed("cancel_input"):
		target = _selected_teenager
		
		if state_machine.get_current_state() != 'Spawning' and state_machine.get_current_state() != 'Deployment':
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
		kinematic_player.move_and_slide(dir * speed)
		
		return false
	else: 
		current_path = []
		return true

#start to attack the teenager
func attack(teenager):
	#TODO: check if the teenager is fighting before killig him
	#TODO: check if he's not dead already
	teenager.state_machine.force_state("Dead")

#remove the player hunter
func _free():
	game.disable_spawn_points()
	exiting = true
	#this signal is used by the 'Game' script to detect when to exit the 
	#hunter mode.
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
		$KinematicPlayer/IndoorLabel.text = "Indoor"
	else:
		$KinematicPlayer/IndoorLabel.text = "Outdoor"

#the teenager target this player selected with right click
func select_target(target):
	_selected_teenager = target
	
#check if the teenager can see the player hunter
func check_teenager_sight():
	if not is_deployed:
		return
		
	for teen in teenager_on_sight:
		var teen_pos = teen.global_position.normalized()
		var player_pos = kinematic_player.global_position.normalized()
		var distance = teen.global_position.distance_to(kinematic_player.global_position)
		var dir = teen_pos - player_pos
		var behind_wall = false
		
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
			if distance < 80 and is_indoor == teen.is_indoor:
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





