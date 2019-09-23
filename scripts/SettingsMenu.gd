extends Control

"""
	Control the settings menu
"""

signal closed

#initialize settings
func _ready():
	$Panel/SoundSlider.set_value(settings.sound_db)
	$Panel/MusicSlider.set_value(settings.music_db)
	
func on_back():
	emit_signal("closed")
	queue_free()

func change_sound(value):
	settings.set_sound_db(value)

func change_music(value):
	settings.set_music_db(value)
