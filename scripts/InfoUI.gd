extends Control

"""
	This UI element will show several informations about the current game.
	Things like score, death progress and time.
"""

var base = null
var points = 0

#world nodes
onready var _score = $InfoPanel/Score

#constructor
func init(base):
	self.base = base
	
func _process(delta):
	if base == null:
		return
		
	_score.text = str(score.get_score(base.game.get_level()))