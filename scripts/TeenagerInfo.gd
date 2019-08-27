extends Control

"""
	This UI element will show some of the teenager information.
"""

var base = null
var selected_teenager = null
var _is_mouse_over = false
var _mouse_click_pos = Vector2(-666,-666)

onready var stats = [$Panel/Stat1,$Panel/Stat2,$Panel/Stat3] 
onready var _panel_default_position = $Panel.rect_global_position

#initialize
func init(base):
	self.base = base
	
	#connect teenagers selection signal
	for teenager_btn in base.get_teenagers_buttons():
		teenager_btn.connect("pressed",self,"show_panel",[teenager_btn.get_parent()])
	
#update teenager information
func _process(delta):
	if selected_teenager == null:
		set_process(false)
		return
		
	#update teenagers info
	$Panel/Gender.text = str(selected_teenager.get_gender())
	$Panel/Fear.text = "Fear: " + str(int(selected_teenager.get_fear()))
	$Panel/Curiosity.text = "Cur.: " + str(int(selected_teenager.get_curiosity()))
	$Panel/Traps.text = "TRAPS: " + str(selected_teenager.traps.size())
	$Panel/TrapsID.text = "TRAP ID: " + str(selected_teenager.current_trap)
	$Panel/STATE.text = str(selected_teenager.state_machine.get_current_state())
			
	
	#drag the panel
	if _is_mouse_over and _mouse_click_pos != Vector2(-666,-666):
		var new_pos = Vector2(get_global_mouse_position().x-$Panel.get_rect().size.x/2,
		get_global_mouse_position().y-$Panel.get_rect().size.y/2)
		$Panel.rect_global_position = new_pos
	
	#recovery button
	if selected_teenager.state_machine.get_current_state() == 'Dead':
		$Panel/RecoverButton.show()
	else: $Panel/RecoverButton.hide()
	
	#drawing function
	update()

#select/release the panel
func _input(event):
	if Input.is_action_just_pressed("ok_input") and _mouse_click_pos == Vector2(-666,-666):
		_mouse_click_pos = get_global_mouse_position()
	if Input.is_action_just_released("ok_input"):
		_mouse_click_pos = Vector2(-666,-666)

#show the panel with the information for one teenager
func show_panel(teenager):
	if base.game.get_current_mode() == base.game.MODE.HUNTING:
		return
	
	$Panel.show()
	selected_teenager = teenager
	set_process(true)
	
	#AI static info
	$Panel/Mugshot.texture_normal = selected_teenager.mugshot
	$Panel/Name.text = selected_teenager.teen_name
	fill_traits()

#hide the panel
func hide_panel():
	$Panel.hide()
	$Panel.rect_global_position = _panel_default_position
	selected_teenager = null
	update()
	fill_traits(true)

func _draw():
	if selected_teenager != null:
		#draw a line from the panel to the teenager position
		var camera_node = base.get_parent().get_player_controller().camera
		var camera = camera_node.global_position
		var teenager_pos = selected_teenager.get_position() - camera
		#no idea why the player position has a wrong offset
		#I will fix it here.
		teenager_pos.y+=90
		teenager_pos.x-=20
		
		##TODO: correct the offset created by zooming the camera##
		
		draw_line(teenager_pos,$Panel.rect_global_position,Color.red)
	
func mouse_entered():
	_is_mouse_over = true

func mouse_exited():
	_is_mouse_over = false
	_mouse_click_pos = Vector2(-666,-666)

#the recover button is pressed
func recovery_pressed():
	if base.game.body_recovery_cost > base.game.get_points():
		#TODO: give a warning to the player
		print('No more points, mate.')
		return
	
	selected_teenager.emit_signal("recover_teen")
	base.game.set_points(base.game.get_points()-base.game.body_recovery_cost)
	hide_panel()
	base.emit_signal("element_changed_focus")

#fill labels for traits
func fill_traits(hide=false):
	if hide:
		#clean all traits label
		for label in stats:
			label.text = ""
		return
		
	#fill labels
	if selected_teenager.traits.keys().size() != 0:
		var trait_id = 0
		for trait in selected_teenager.traits.keys():
			if trait_id > stats.size()-1:
				print('no more labels for filling the traits')
				return
				
			var txt_trait = ""
			match trait:
				selected_teenager.TRAITS.HORNY:
					txt_trait = "horny"
				selected_teenager.TRAITS.SLOW:
					txt_trait = "slow"
				selected_teenager.TRAITS.FAST:
					txt_trait = "fast"
				selected_teenager.TRAITS.FINAL_GIRL:
					txt_trait = "final girl"
				selected_teenager.TRAITS.DIARRHEA:
					txt_trait = "diarrhea"
					
			stats[trait_id].text = txt_trait
			
			trait_id += 1














