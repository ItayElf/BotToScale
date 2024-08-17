extends CharacterBody2D

@export var speed: float = 300.0

## Sets the velocity from the user input
func _change_velocity():
	var direction_x = Input.get_axis("ui_left", "ui_right")
	if direction_x:
		velocity.x = direction_x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	var direction_y = Input.get_axis("ui_up", "ui_down")
	if direction_y:
		velocity.y = direction_y * speed
	else:
		velocity.y = move_toward(velocity.x, 0, speed)

func _physics_process(delta):
	_change_velocity()
	move_and_slide()
