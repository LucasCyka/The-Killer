extends Control

"""
	This UI element will show some of the teenager information.
"""

var base = null

#TODO: make this panel movable
#TODO: a line going from the panel to the selected teenager

#initialize
func init(base):
	self.base = base
	
	#connect teenagers selection signal
	for teenager_btn in base.get_teenagers_buttons():
		teenager_btn.connect("pressed",self,"show_panel",[teenager_btn.get_parent().get_parent()])
	
	
#show the panel with the information for one teenager
func show_panel(teenager):
	$Panel.show()
	pass