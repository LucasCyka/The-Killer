extends Node2D

"""
	Controls the main menu and intro of the game.
"""

func _input(event):
	if Input.is_action_just_pressed("Enter"):
		$BackgroundAnimation/AnimationPlayer.play("New Anim")
		pass
	pass