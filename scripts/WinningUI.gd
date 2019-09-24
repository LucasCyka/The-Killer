extends Control

"""
	Control the panel that appear when the player wins the level
"""

var base

#world nodes
onready var panel = $Panel

#initialiaze
func init(base):
	self.base = base
	
	self.base.game.connect('game_won_music',self,'show_panel')

#ending screen and all the information
func show_panel():
	panel.show()
	
	#update newgrounds score
	var score_id = score.scores_id[base.game.get_level()]
	var api = base.get_node("NewGroundsAPI")
	
	api.ScoreBoard.postScore(score.get_score(base.game.get_level()),score_id)
	var result = yield(api, 'ng_request_complete')
	if api.is_ok(result):
		print('Session: ' + str(result.response))
	else:
		print('Error: ' + result.error)
	
	#TODO: fill points, score etc...
	
#goes to the main menu
func menu_btn():
	for teen in get_tree().get_nodes_in_group("AI"):
		teen.free()
	var player = base.game.get_player()
	if player != null: player.queue_free()
	
	get_tree().change_scene("res://scenes/MainMenu.tscn")
	star.clear()
	
#restarts game
func restart_btn():
	for teen in get_tree().get_nodes_in_group("AI"):
		teen.free()
	var player = base.game.get_player()
	if player != null: player.queue_free()
	
	#TODO: loading screen
	get_tree().reload_current_scene()
	star.clear()