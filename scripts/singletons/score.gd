extends Node

"""
	This singleton will store score informations
"""

#score for each level
var scores = {
	"res://scenes/prototype.tscn":0
	
} 

func set_score(stage,value):
	scores[stage] = value

func get_score(stage):
	return scores[stage]
