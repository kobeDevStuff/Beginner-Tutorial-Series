extends CharacterBody2D

## Author: Kobe Della Favory
## Updated: 18/03/26

# Constants cannot be changed in the script
const SPEED := 1000.0
const ACCEL: float = 5.0


#func _ready() -> void: -> awake/start in unity
#func _process(delta: float) -> void:
#func _physics_process(delta: float) -> void:

# Returns a UNIT VECTOR that points to where our character should move
func get_input() -> Vector2:
	var direction: Vector2
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return direction.normalized()

# Called every physics frame
func _physics_process(delta: float) -> void:
	var player_input: Vector2 = get_input()
	
	# SPEED is the magnitude of our velocity
	# ACCEL * delta is our acceleration of the character
	# we multiply by delta in order to account for variable frame rates on different monitors
	velocity = lerp(velocity, player_input * SPEED, ACCEL * delta) # lineraly interpolate the current velocity to the target velocity to acheive a smooth effect
	move_and_slide() # call move_and_slide in physics process
	# If your character jitters, make sure to go to Project -> Project settings -> Physics -> Common -> Enable physics interpolation
	
