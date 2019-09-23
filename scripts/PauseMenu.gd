extends Control

"""
	Control the in-game pause menu
"""

var base = null

onready var btns = [$RestartBtn,$OptionsBtn,$CreditsBtn,$ExitBtn]
var selected_btn = 0
var _selected_normal = null

#initialize
func init(base):
	self.base = base
	
	btns[selected_btn].get_child(0).show()
	_selected_normal = btns[selected_btn].texture_normal
	btns[selected_btn].texture_normal = btns[selected_btn].texture_hover
	
	for btn in btns:
		btn.connect('mouse_entered',self,'_on_hover',[btn])


#when the button is hovered with the mouse
func _on_hover(btn):
	if btns.find(btn) == selected_btn: return
	btns[selected_btn].get_child(0).hide()
	btns[selected_btn].texture_normal = _selected_normal
	
	selected_btn = btns.find(btn)
	btns[selected_btn].get_child(0).show()
	_selected_normal = btns[selected_btn].texture_normal
	btns[selected_btn].texture_normal = btns[selected_btn].texture_hover

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		if not is_visible() and base.game.get_current_mode() != base.game.MODE.HUNTING:
			if get_tree().get_nodes_in_group("Player").size() == 0:
				show()
		elif is_visible():
			hide()
	
	if not self.is_visible(): return
	
	var changed = false
	var new_btn = selected_btn
	
	if Input.is_action_just_pressed("Down"):
		btns[selected_btn].get_child(0).hide()
		btns[selected_btn].texture_normal = _selected_normal
		new_btn += 1
		changed = true
	elif Input.is_action_just_pressed("Up"):
		btns[selected_btn].get_child(0).hide()
		btns[selected_btn].texture_normal = _selected_normal
		new_btn -= 1
		changed = true
	elif Input.is_action_just_pressed("Enter"):
		if btns[selected_btn] == $RestartBtn: on_restart()
		elif btns[selected_btn] == $OptionsBtn: on_options()
		elif btns[selected_btn] == $CreditsBtn: on_credits()
		elif btns[selected_btn] == $ExitBtn: exit()
		else: return
	else:
		return
	
	if changed:
		if new_btn == btns.size(): new_btn = 0
		elif new_btn == -1: new_btn = btns.size()-1
		
		selected_btn = new_btn
		btns[selected_btn].get_child(0).show()
		_selected_normal = btns[selected_btn].texture_normal
		btns[selected_btn].texture_normal = btns[selected_btn].texture_hover
	

#restart button pressed event
func on_restart():
	get_tree().paused = false
	for teen in get_tree().get_nodes_in_group("AI"):
		teen.free()
	
	#TODO: loading screen
	get_tree().reload_current_scene()
	star.clear()

#credits button pressed event
func on_credits():
	var credits = preload("res://scenes/Credits.tscn").instance()
	get_parent().add_child(credits)
	credits.connect('closed',self,'show')

#options button pressed event
func on_options():
	var options = preload("res://scenes/SettingsMenu.tscn").instance()
	get_parent().add_child(options)
	options.connect('closed',self,'show')

func exit():
	get_tree().paused = false
	for teen in get_tree().get_nodes_in_group("AI"):
		teen.free()
	
	#TODO: loading screen
	get_tree().change_scene("res://scenes/MainMenu.tscn")
	star.clear()
	

