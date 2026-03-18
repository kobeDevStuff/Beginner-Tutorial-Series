extends RigidBody2D

## Author: Kobe Della Favory
## Updated: 18/03/26

# @export_range, @export, @export_enum, etc. all create interactive sliders in the inspector dock in the right,
# these are really useful, saved to your disk, and update the game as soon as you change the value!
@export_range(0, 50, 0.1) var ACCELERATION: float = 10.0 # How 'slippery' the character feels
@export_range(0, 50, 0.1) var MAX_SPEED: float = 10.0 # Maximum velocity the character can travel

# vv I've added this after the tutorial vv
@export_range(0, 200, 0.1) var STOP_DISTANCE: float = 100

# My character's mass is set to 0.01kg in the editor, alternatively, you can change this in code in the _ready function below
func _ready() -> void:
	mass = 0.01
	gravity_scale = 0 # this ensures the character floats and moves instead of falling down

# Called during physics processing, allowing you to read and safely modify the simulation state for the object. 
# By default, it is called before the standard force integration.
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	
	var resultant: Vector2 = (mouse_pos - global_position) # We aren't normalising the vector yet to check how far the mouse is from the character!
	
	if resultant.length() > STOP_DISTANCE: # this triggers IF the mouse is far enough away from the character
		state.apply_central_force(resultant.normalized() * ACCELERATION) # Move player
		
		state.linear_velocity.limit_length(MAX_SPEED) # Limit the speed of player
		
		look_at(mouse_pos) # Rotate player
	
