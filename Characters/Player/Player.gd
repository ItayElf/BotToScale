class_name Player 
extends CharacterBody2D

# States for the player (UNASSIGNED is only used before start_state is assigned to current_state)
enum State {ROOMBA, BLENDER, COFFEE, REFRIGERATOR, FAN, UNASSIGNED}

@export_group("State specific")
@export_subgroup("Roomba")
@export var roomba_speed: float = 300.0
@export var roomba_acceleration: float = 1300.0
@export var roomba_deceleration: float = 1500.0
@export_subgroup("Blender")
@export var blender_speed: float = 300.0
@export var blender_acceleration: float = 1300.0
@export var blender_deceleration: float = 1500.0
@export var blender_damage_per_second: float = 130.0
@export_subgroup("Coffee")
@export var coffee_speed: float = 300.0
@export var coffee_acceleration: float = 1300.0
@export var coffee_deceleration: float = 1500.0
@export_subgroup("Refrigerator")
@export var refrigerator_speed: float = 300.0
@export var refrigerator_acceleration: float = 1300.0
@export var refrigerator_deceleration: float = 1500.0
@export_subgroup("Fan")
@export var fan_speed: float = 300.0
@export var fan_acceleration: float = 1300.0
@export var fan_deceleration: float = 1500.0
@export var fan_push_time_to_max_velocity : float = 1.0
@export var fan_push_max_speed : float = 1000.0
@export_group("Switching states")
@export var start_state : State = State.ROOMBA

var speed : float
var acceleration : float
var deceleration : float
var current_state : State = State.UNASSIGNED
var input : Vector2
var hitlist : Array[Enemy]

# These are colliders that hold everything that
# a specific player state would need (sprite, timers, etc.)
@onready var roomba = $Roomba
@onready var blender = $Blender
@onready var coffee = $Coffee #that's what i'm calling the coffee machine
@onready var refrigerator = $Refrigerator
@onready var fan = $Fan


func _ready():
	change_state(start_state)

## Sets the velocity from the user input
func _change_velocity(delta):
	# gets the input vector (horizontal_input, vertical_input)
	input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# change the size of this vector to 1 to limit the diagonal movement speed
	input = input.normalized()
	
	# if you press any keys you accelerate until reaching the max speed 
	if input:
		velocity = velocity.move_toward(input * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

func _process(delta):
	match current_state:
		State.BLENDER:
			blender_behaviour(delta)
		State.FAN:
			fan_behaviour(delta)
			
	# REMOVE BEFORE FINAL BUILD
	DEBUG_state_changer()

func _physics_process(delta):
	_change_velocity(delta)
		
	move_and_slide()

func DEBUG_state_changer():
	if Input.is_action_just_pressed("roomba"):
		change_state(State.ROOMBA)
	elif Input.is_action_just_pressed("blender"):
		change_state(State.BLENDER)
	elif Input.is_action_just_pressed("coffee"):
		change_state(State.COFFEE)
	elif Input.is_action_just_pressed("refrigerator"):
		change_state(State.REFRIGERATOR)
	elif Input.is_action_just_pressed("fan"):
		change_state(State.FAN)

func change_state(state : State):
	
	# Disable the last state
	match current_state:
		State.UNASSIGNED:
			roomba.visible = false
			roomba.disabled = true
		State.ROOMBA:
			roomba.visible = false
			roomba.disabled = true
		State.BLENDER:
			blender.visible = false
			blender.disabled = true
		State.COFFEE:
			coffee.visible = false
			coffee.disabled = true
		State.REFRIGERATOR:
			refrigerator.visible = false
			refrigerator.disabled = true
		State.FAN:
			fan.visible = false
			fan.disabled = true
	
	current_state = state
	
	# Enable the new state and change the appropriate stats
	match current_state:
		State.ROOMBA:
			roomba.visible = true
			roomba.disabled = false
			
			speed = roomba_speed
			acceleration = roomba_acceleration
			deceleration = roomba_deceleration
		State.BLENDER:
			blender.visible = true
			blender.disabled = false
			
			speed = blender_speed
			acceleration = blender_acceleration
			deceleration = blender_deceleration
		State.COFFEE:
			coffee.visible = true
			coffee.disabled = false
			
			speed = coffee_speed
			acceleration = coffee_acceleration
			deceleration = coffee_deceleration
		State.REFRIGERATOR:
			refrigerator.visible = true
			refrigerator.disabled = false
			
			speed = refrigerator_speed
			acceleration = refrigerator_acceleration
			deceleration = refrigerator_deceleration
		State.FAN:
			fan.visible = true
			fan.disabled = false
			
			speed = fan_speed
			acceleration = fan_acceleration
			deceleration = fan_deceleration

func add_health(amount: float):
	print("healed by: " + str(amount))
	pass # TODO: implement

func _on_any_trigger_body_entered(body):
	if body is Enemy:
		hitlist.append(body)

func _on_any_trigger_body_exited(body):
	if body is Enemy:
		var id = hitlist.find(body)
		if id != -1:
			hitlist.remove_at(id)

func blender_behaviour(delta):
	if Input.is_action_pressed("ability"):
		blender.get_node("AttackTrigger/CollisionShape2D").disabled = false
				
		var rotation_value : float
		var direction_to_mouse = position.direction_to(get_global_mouse_position())
				
		#This allows us to determine whether the mouse is placed horizontally
		# with the player or vertically to rotate the attack trigger
		var dot_product = direction_to_mouse.dot(Vector2.UP)
				
		if dot_product * dot_product > 0.5:
			if direction_to_mouse.y > 0:
				rotation_value = 90.0
			else:
				rotation_value = -90.0
		else:
			if direction_to_mouse.x > 0:
				rotation_value = 0.0
			else:
				rotation_value = 180.0
					
		blender.get_node("AttackTrigger").rotation_degrees = rotation_value
				
		# Deal damage to all enemies in the attack trrigger
		for hit in hitlist:
			if hit.has_method("get_hit"):
				hit.get_hit(blender_damage_per_second * delta)
	
	if Input.is_action_just_released("ability"):
		blender.get_node("AttackTrigger/CollisionShape2D").disabled = true

func fan_behaviour(delta):
	if Input.is_action_pressed("ability"):
		fan.get_node("PushTrigger/CollisionShape2D").disabled = false
		
		var rotation_value : float
		var direction_to_mouse = position.direction_to(get_global_mouse_position())
				
		#This allows us to determine whether the mouse is placed horizontally
		# with the player or vertically to rotate the attack trigger
		var dot_product = direction_to_mouse.dot(Vector2.UP)
		var looking_dir : Vector2
		
		if dot_product * dot_product > 0.5:
			if direction_to_mouse.y > 0:
				rotation_value = 90.0
				looking_dir = Vector2.DOWN
			else:
				rotation_value = -90.0
				looking_dir = Vector2.UP
		else:
			if direction_to_mouse.x > 0:
				rotation_value = 0.0
				looking_dir = Vector2.RIGHT
			else:
				rotation_value = 180.0
				looking_dir = Vector2.LEFT
					
		fan.get_node("PushTrigger").rotation_degrees = rotation_value
		
		var new_acceleration = fan_push_max_speed / fan_push_time_to_max_velocity
		for hit in hitlist:
			hit.velocity = hit.velocity.move_toward(looking_dir * fan_push_max_speed, 
					new_acceleration * delta)
	
	if Input.is_action_just_released("ability"):
		fan.get_node("PushTrigger/CollisionShape2D").disabled = true
