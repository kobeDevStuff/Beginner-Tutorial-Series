extends Node

# drag into editor by holding ctrl/cmd
const PHYSICS_PLAYER = preload("res://scenes/physics_player.tscn")

func _ready() -> void:
	for i in range(10):
		var instance : PhysicsPlayer = PHYSICS_PLAYER.instantiate() # Generates a reference to the node about to be added
		instance.position = Vector2(randi_range(0,1080), randi_range(0,1080)) # Do something here before we add it as a child!
		add_child(instance) # Finally, add it into the scene tree, either as a direct child or link it to a seperate node like PlayerPool etc.
