extends Node

"""
	This singleton will store score informations
"""

signal score_changed
signal killing_score_changed

#score for each level
var scores = {
	"res://scenes/prototype.tscn":0,
	"res://scenes/prototype2.tscn":0,
	"res://scenes/Level1.tscn":0
	
} 
#the 'killings score' for each level
var killing_scores = {
	"res://scenes/prototype.tscn":0,
	"res://scenes/prototype2.tscn":0,
	"res://scenes/Level1.tscn":0
}

var scores_id = {
	"res://scenes/prototype2.tscn":8708,
	"res://scenes/Level1.tscn":8709
}

func set_score(stage,value):
	scores[stage] = value
	emit_signal("score_changed")
	
func get_score(stage):
	return scores[stage]

func set_killing_score(stage,value):
	killing_scores[stage] = value
	emit_signal("killing_score_changed")
	
func get_killing_score(stage):
	return killing_scores[stage]