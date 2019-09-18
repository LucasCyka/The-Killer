extends Control

"""
	This UI element will show several informations about the current game.
	Things like score, death progress and time.
"""

var base = null
var points = 0
var activated_teens = []
var teens = []
var spawn_pointers_data = {}

#used for highlighting pressed buttons on the clock
var btn_textures_temp = {}

#world nodes
onready var game = get_parent().get_parent().get_parent()
onready var _score = $InfoPanel/Score
onready var _points = $InfoPanel/Points
onready var fc_slots = $FCSlots.get_children()
onready var _killing_score = $InfoPanel/KillingScore
onready var spawn_pointers = $InfoPointers

#f/c bars textures
onready var red_bar = preload('res://sprites/gui/fc_progress_bar3.png')
onready var orange_bar = preload('res://sprites/gui/fc_progress_bar2.png')
onready var green_bar = preload('res://sprites/gui/fc_progress_bar.png')

#used in the pointer syste,
const pointer_right = 587
const pointer_left = 12
const pointer_up = 12
const pointer_down = 354

#constructor
func init(base):
	self.base = base
	self.teens = base.game.get_teenagers()
	highlight_clock($Clock/NormalSpdBtn)
	init_spawn_pointers()
	score.connect("score_changed",self,"update_score")
	score.connect("killing_score_changed",self,"update_killing_score")
	base.game.connect('changed_points',self,'update_points')
	
func _process(delta):
	if base == null:
		return
	self.teens = base.game.get_teenagers()
	update_time()
	update_spawn_pointers()
	#search for teens that aren't on routine
	for teen in teens:
		#prevent some errors when the teenager is erased
		if not is_instance_valid(teen):
			activated_teens.erase(teen)
			break
		
		#when sleeping/dying the teen routine will be interrupted, but the player
		#don't need to see his status
		var is_sleeping = teen.state_machine.get_current_state() == 'Sleeping'
		var is_dead = teen.state_machine.get_current_state() == 'Dead'
		var is_love = teen.state_machine.get_current_state() == 'InLove'
		var is_shitting = teen.state_machine.get_current_state() == 'Shitting'
		
		if teen.is_routine_paused and activated_teens.find(teen) == -1 and not is_sleeping and not is_dead and not is_love and not is_shitting:
			activated_teens.append(teen)
		elif not teen.is_routine_paused and activated_teens.find(teen) != -1:
			activated_teens.erase(teen)
		elif (is_sleeping or is_dead) and activated_teens.find(teen) != -1:
			activated_teens.erase(teen)
		else: continue
		
	if activated_teens != []:
		fill_fc_slots()
	else: clear_fc_slots()
	
	#number of teens killed/remaining
	var alive = base.game.get_teenagers_alive().size()
	var ingame =  base.game.get_teenagers_num() 
	$InfoPanel/Teens.text = str(ingame - alive) + "/" + str(ingame)
	
	#show the player if the game is paused
	if base.game.current_mode == base.game.MODE.PAUSED:
		$InfoPanel/Paused.show()
	else:
		$InfoPanel/Paused.hide()

#TODO: slot animations
#fill the fear/curiosity slots of teenagers that aren't on routine.
func fill_fc_slots():
	var teen_id = 0
	for teen in activated_teens:
		if teen_id > fc_slots.size()-1:
			#no more slots
			break
		
		if not is_instance_valid(teen):
			activated_teens.erase(teen)
			break
		
		var fear_bar = fc_slots[teen_id].get_node('FearProgress')
		var curiosity_bar = fc_slots[teen_id].get_node('CuriosityProgress')
		var portrait_btn = fc_slots[teen_id].get_node("PortraitBtn")
		
		fear_bar.set_value(teen.get_fear())
		curiosity_bar.set_value(teen.get_curiosity())
		fc_slots[teen_id].show()
		
		
		#the fear progress bar will change its colors/texture according to its
		#level.
		#also the portrait will change according to the level of 
		#fear/curiosity.
		if fear_bar.get_value() >= 50:
			fear_bar.set_progress_texture(red_bar)
			portrait_btn.texture_normal = teen.portrait_panic
		elif fear_bar.get_value() >= 33:
			fear_bar.set_progress_texture(orange_bar)
			portrait_btn.texture_normal = teen.portrait_fear
		else:
			fear_bar.set_progress_texture(green_bar)
			portrait_btn.texture_normal = teen.portrait_neutral
		
		teen_id += 1
	
	#clean not used slots
	var slot_id = 0
	for slot in fc_slots:
		if slot_id > teen_id-1:
			slot.hide()
		slot_id += 1
		
	
func clear_fc_slots():
	for slot in fc_slots:
		slot.hide()

#update the time label
func update_time():
	var time_label = $Clock/Label
	#'raw' time in minutes
	var time = base.game.get_time()
	
	var hour = int(time / 60)
	var minute = time - (hour * 60)
	
	if fmod(hour,12) != 0 : hour = fmod(hour,12)
	
	#convert to string
	if hour < 10: hour = '0'+str(hour)
	else: hour = str(hour)
	
	if minute < 10: minute = '0'+str(minute)
	else: minute = str(minute)
	
	time_label.text = hour + ':' + minute
	
	#little icon on the clock
	if time/60 > 19 or time/60 < 6:
		$Clock/TimeIcon.texture = preload("res://sprites/gui/timeIcon_moon.png")
	else:
		$Clock/TimeIcon.texture = preload("res://sprites/gui/timeIcon_sun.png")

#highlight a button currently pressed on the clock GUI
func highlight_clock(btn):
	if btn_textures_temp.empty():
		btn_textures_temp = {btn:[btn.texture_normal,btn.texture_hover]}
		
		btn.texture_normal = btn.texture_pressed
		btn.texture_hover = btn.texture_pressed
		return
	
	#take the highligt off the previous button
	var previous = btn_textures_temp.keys()[0]
	previous.texture_normal = btn_textures_temp[previous][0]
	previous.texture_hover = btn_textures_temp[previous][1]
	
	btn_textures_temp = {btn:[btn.texture_normal,btn.texture_hover]}
	
	#highligh btn
	btn.texture_normal = btn.texture_pressed
	btn.texture_hover = btn.texture_pressed
	
#pause/resume the game
func pause_btn():
	base.game.audio_system.play_sound('Click')
	if base.game.get_current_mode() == base.game.MODE.PAUSED:
		base.game.resume_game()
		base.game.update_time_speed(base.game.default_speed)
		highlight_clock($Clock/NormalSpdBtn)
	else:
		highlight_clock($Clock/PauseBtn)
		base.game.pause_game()

#change the game time to the default setting
func normal_btn():
	base.game.audio_system.play_sound('Click')
	highlight_clock($Clock/NormalSpdBtn)
	
	if base.game.timer_speed != base.game.default_speed and base.game.get_current_mode() != base.game.MODE.PAUSED:
		base.game.update_time_speed(base.game.default_speed)
	elif base.game.get_current_mode() == base.game.MODE.PAUSED:
		base.game.resume_game()
		base.game.update_time_speed(base.game.default_speed)
	else:
		return

#change the game time to the fast setting
func fast_btn():
	base.game.audio_system.play_sound('Click')
	highlight_clock($Clock/FastSpdBtn)
	
	if base.game.timer_speed != base.game.fast_speed  and base.game.get_current_mode() != base.game.MODE.PAUSED:
		base.game.update_time_speed(base.game.fast_speed)
	elif base.game.get_current_mode() == base.game.MODE.PAUSED:
		base.game.resume_game()
		base.game.update_time_speed(base.game.fast_speed)
	else:
		return

#change the game time to the fast setting
func fast_btn2():
	base.game.audio_system.play_sound('Click')
	highlight_clock($Clock/FastSpdBtn2)
	
	if base.game.timer_speed != base.game.ultra_speed and base.game.get_current_mode() != base.game.MODE.PAUSED:
		base.game.update_time_speed(base.game.ultra_speed)
	elif base.game.get_current_mode() == base.game.MODE.PAUSED:
		base.game.resume_game()
		base.game.update_time_speed(base.game.ultra_speed)
	else:
		return

#called when a new score is set. This function set, format and trigger an
#animation in  the score label.
func update_score():
	_score.text = str(score.get_score(base.game.get_level()))
	#formatting
	if _score.text.length() < 7:
		for gap in 7-_score.text.length():
			_score.text = _score.text.insert(0,'0')
			
	base.play_label_animation('score')

#called when a new killing is set.
func update_killing_score():
	_killing_score.text = str(score.get_killing_score(base.game.get_level())) + "%"
	#TODO: maybe some animations?

func update_points():
	_points.text = "$"+str(game.get_points())
	
	#formating
	if fmod(1000,game.get_points()) or game.get_points() == 1000:
		_points.text = _points.text.insert(_points.text.length()-3,',')

#initialize the pointers that will show the player where the spawn points are
func init_spawn_pointers():
	var pointers = spawn_pointers.get_children()
	var spawn_locations = game.get_spawn_points()
	
	for point in range(spawn_locations.get_used_cells().size()):
		#used to mark where the spawn points will be
		var spr_pos = Sprite.new()
		spr_pos.name = 'SpawnPosition'
		game.add_child(spr_pos)
		
		spr_pos.global_position = spawn_locations.map_to_world(spawn_locations.get_used_cells()[point])
		
		spawn_pointers_data[pointers[point]] = spr_pos

#point to where the spawn points are
func update_spawn_pointers():
	if not game.get_spawn_points().is_visible():
		#player not trying to spawn, hide everything
		if spawn_pointers_data.keys() != []:
			for pointer in spawn_pointers_data.keys():
				pointer.hide()
		return
	
	var camera = game.get_player_controller().camera
	var fixed_camera = Vector2(camera.global_position.x+300,camera.global_position.y+188)
	
	#the player is trying to spawn, show the direction of the spawn points
	for pointer in spawn_pointers_data:
		var pos = spawn_pointers_data[pointer].get_global_transform_with_canvas().origin
		
		if (pos.x> 0 and pos.x <= 600) and (pos.y >0 and pos.y <= 375):
			pointer.hide()
		else:
			pointer.show()
			
			#positions and rotation
			var pointer_x = clamp(pos.x,10,590)
			var pointer_y = clamp(pos.y,10,365)
			pointer.global_position.x = pointer_x
			pointer.global_position.y = pointer_y
			
			pointer.look_at(pos)
		
		
	
















