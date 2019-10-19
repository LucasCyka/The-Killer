extends Control

"""
	Controls the selection panel menu.
"""

signal closed

onready var btns = [$Panel/Level1Btn,$Panel/Level2Btn]
onready var levels = ['res://scenes/prototype2.tscn',
'res://scenes/Level1.tscn']

var score_ids = [8708,8709]
var selected_level = 0
var _selected_normal = null
var description = null
var busy = false

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
	if not busy: update_score()

func update_description():
	$Panel/Description.text = str(description['Text'][levels[selected_level]])

func update_difficulty():
	#TODO
	pass

func update_score():
	busy = true
	
	var score_labels = [$Panel/ScoreTable1,$Panel/ScoreTable2,$Panel/ScoreTable3,
	$Panel/ScoreTable4,$Panel/ScoreTable5]
	
	for label in range(score_labels.size()):
		score_labels[label].text = str(label+1) + 'th - Loading...' 
	
	
	$NewGroundsAPI.ScoreBoard.getBoards()
	var result = yield($NewGroundsAPI, 'ng_request_complete')
	
	if $NewGroundsAPI.is_ok(result):
		var id = result.response['scoreboards'][selected_level]['id']
		#scoreId, sessionId=api.session_id, limit=10, skip=0, 
		#social=false, tag=null, period=null, userId=null
		$NewGroundsAPI.ScoreBoard.getScores(id,$NewGroundsAPI.session_id,5,0,false,null,'A')
		result = yield($NewGroundsAPI, 'ng_request_complete')
		
		#show 5 best scores for this level
		for label in range(score_labels.size()):
			if result.response['scores'] == [] or label+1 > result.response['scores'].size():
				score_labels[label].text = str(label+1) + 'th -'
			else:
				var _name = str(result.response['scores'][label]['user']['name'])
				score_labels[label].text = str(label+1) + 'th - ' + _name
		
		
	else:
		#couldn't load scores, just fill with errors
		for label in range(score_labels.size()):
			score_labels[label].text = str(label+1) + 'th - Error...' 
		
		print('Error: ' + result.error)
	
	busy = false

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


























