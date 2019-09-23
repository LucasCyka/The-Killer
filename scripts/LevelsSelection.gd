extends Control

"""
	Controls the selection panel menu.
"""

signal closed

onready var btns = [$Panel/Level1Btn,$Panel/Level2Btn]
onready var levels = ['res://scenes/prototype2.tscn',
'res://scenes/Level1.tscn']

var selected_level = 0
var _selected_normal = null
var description = null

#initialize
func _ready():
	_selected_normal = btns[selected_level].texture_normal
	btns[selected_level].texture_normal = btns[selected_level].texture_hover
	
	for btn in btns:
		btn.connect('pressed',self,'level_pressed',[btn])
		
	var file = File.new()
	description = file.open("res://resources/json/levels_desc.json",File.READ)
	description = parse_json(file.get_as_text())
	
	update_description()
	update_difficulty()
	update_score()
	
func level_pressed(btn):
	if btns.find(btn) == selected_level: return
	
	btns[selected_level].texture_normal = _selected_normal
	selected_level = btns.find(btn)
	
	_selected_normal = btns[selected_level].texture_normal
	btns[selected_level].texture_normal = btns[selected_level].texture_hover
	
	update_difficulty()
	update_description()
	update_score()

func update_description():
	$Panel/Description.text = str(description['Text'][levels[selected_level]])

func update_difficulty():
	#TODO
	pass

func update_score():
	pass

func back():
	emit_signal("closed")
	queue_free()

#when on play btn event
func play():
	var loader = preload('res://scenes/LoadingScreen.tscn').instance()
	add_child(loader)
	var current = get_parent()
	if get_parent().name == 'MainMenu':
		get_parent().get_node('BackgroundAnimation').hide()
	
	loader.init(levels[selected_level],current)
	get_node("Panel").hide()









