extends Control

"""
	Controls the credits panel.
"""

signal closed

func on_back():
	emit_signal("closed")
	queue_free()