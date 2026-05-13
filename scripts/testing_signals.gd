extends Node
## Author: Kobe Della Favory
## Updated: 13/05/26

func _ready() -> void:
	var parent : MainMenu = get_parent() # Getting the node we are listening to
	parent.transition.connect(_on_main_menu_transition) # Connects a block of code to run whenever this signal occurs

# Not required but try to format like "_on_{node name}_{signal name}"
func _on_main_menu_transition() -> void:
	print("Transition")
