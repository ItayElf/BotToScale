extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 1300.0
@export var deceleration: float = 1500.0

## Sets the velocity from the user input
func _change_velocity(delta):
	# gets the input vector (horizontal_input, vertical_input)
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# change the size of this vector to 1 to limit the diagonal movement speed
	input = input.normalized()
	
	# if you press any keys you accelerate until reaching the max speed 
	if input:
		velocity = velocity.move_toward(input * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

func _physics_process(delta):
	_change_velocity(delta)
	move_and_slide()
