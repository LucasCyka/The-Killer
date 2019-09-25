extends Control

"""
	Achievement GUI.
"""

#medals textures
var textures = {58135:'res://sprites/misc/medals/finish_tutorial.png',
58134:'res://sprites/misc/medals/first_dead.png',
58136:'res://sprites/misc/medals/finish_level2.png',
58132:'res://sprites/misc/medals/secret_donkey.png' 
}

var base

#world nodes
onready var medal_texture = $AchievementSpr
onready var anim_node = $AnimationPlayer 

func init(base):
	self.base = base

#play achievement animation
func play_achievement(id):
	medal_texture.texture = load(textures[id])
	
	if not anim_node.is_connected("animation_finished",self,"finish_animation"):
		anim_node.connect("animation_finished",self,"finish_animation")
		
	anim_node.play("MedalAnim")
	
func finish_animation(anim):
	if anim_node.is_connected("animation_finished",self,"finish_animation"):
		anim_node.disconnect("animation_finished",self,"finish_animation")
	
	anim_node.play_backwards("MedalAnim")









