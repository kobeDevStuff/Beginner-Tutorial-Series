extends Node
class_name MainMenu
signal transition # Making a custom signal

const WORLD := preload("res://scenes/world.tscn")
@onready var play: Button = $Control/Play

func _ready() -> void:
	play.pressed.connect(_on_play_pressed) # This is how to connect a signal through code if you don't want to use the inspector or can't use the inspector

#func _on_play_pressed() -> void:
	#get_tree().change_scene_to_packed(WORLD)

func _on_play_pressed() -> void:
	transition.emit() # Emitting our signal out to whatever may be listening to it
	get_tree().change_scene_to_packed(WORLD) # Changing scene to the world
#	get_tree().change_scene_to_file("res://scenes/world.tscn") # You can also do it like this if you prefer


func _on_quit_pressed() -> void:
	get_tree().quit() # Pretty self-explainatory
