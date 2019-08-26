extends Node

"""
	This singleton will store score informations
"""

signal score_changed

#score for each level
var scores = {
	"res://scenes/prototype.tscn":0,
	"res://scenes/prototype2.tscn":0,
	"res://scenes/Level1.tscn":0
	
} 

func set_score(stage,value):
	scores[stage] = value
	emit_signal("score_changed")
	

func get_score(stage):
	return scores[stage]
