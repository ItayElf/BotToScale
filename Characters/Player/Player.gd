class_name Player
extends CharacterBody2D

# States for the player (UNASSIGNED is only used before start_state is assigned to current_state)
enum State {ROOMBA, BLENDER, COFFEE, REFRIGERATOR, FAN, UNASSIGNED}

@export_group("Health")
@export var max_health : float = 14
@export var start_health = 1
@export var blender_change_health = 3
@export var coffee_change_health = 6
@export var fridge_change_health = 9
@export var fan_change_health = 12

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
@export var blender_knockback_max_speed: float = 200.0
@export var blender_knockback_time_to_max_velocity = 0.1
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
@export_group("Sounds")
@export var footstep_timer_speed_multiplier = 0.005


var speed : float
var acceleration : float
var deceleration : float
var current_state : State = State.UNASSIGNED
var input : Vector2
var hitlist : Array[Enemy]
var health
var can_attack := true
var can_turn := true
var is_alive := true
# These are colliders that hold everything that
# a specific player state would need (sprite, timers, etc.)
@onready var roomba = $Roomba
@onready var blender = $Blender
@onready var coffee = $Coffee #that's what i'm calling the coffee machine
@onready var refrigerator = $Refrigerator
@onready var fan = $Fan

@onready var hud = $HUD
@onready var animator = $"Sprite Animator"
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var attack_finish_timer = $Refrigerator/AttackFinish
@onready var attack_cooldown_timer = $Refrigerator/AttackCooldown

func _ready():
	health = start_health
	hud.update_health_bar(health / max_health)
	change_state(start_state)

## Sets the velocity from the user input
func _change_velocity(delta):
	var last_inp = input
	
	# gets the input vector (horizontal_input, vertical_input)
	input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# change the size of this vector to 1 to limit the diagonal movement speed
	input = input.normalized()
	
	if last_inp == Vector2.ZERO and input != Vector2.ZERO:
		$FootstepTimer.start(1/speed * footstep_timer_speed_multiplier)
	# if you press any keys you accelerate until reaching the max speed 
	if input:
		velocity = velocity.move_toward(input * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

func _process(delta):
	if is_alive:
		match current_state:
			State.BLENDER:
				blender_behaviour(delta)
			State.FAN:
				fan_behaviour(delta)
		
		update_animator()
		
		# REMOVE BEFORE FINAL BUILD
		DEBUG_state_changer()

func play_footstep():
	if current_state == State.REFRIGERATOR:
		MusicController.p_fridge_footstep()
	elif current_state == State.BLENDER or State.COFFEE:
		MusicController.p_metal_footstep()

func _physics_process(delta):
	if is_alive:
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

func update_animator():
	if not can_turn: return
	var right_state = current_state == State.BLENDER or current_state == State.REFRIGERATOR
	if Input.is_action_pressed("ability") and right_state and can_attack:
		var direction_to_mouse = position.direction_to(get_global_mouse_position())
		animation_tree.set("parameters/Idle/blend_position", direction_to_mouse)
		animation_tree.set("parameters/Move/blend_position", direction_to_mouse)
		animation_tree.set("parameters/Ability/blend_position", direction_to_mouse)
		var should_flip = $Roomba/Sprite.flip_h and direction_to_mouse.x > 0 or not $Roomba/Sprite.flip_h and direction_to_mouse.x < 0
		if should_flip:
			flip_sprites()
		
		if Input.is_action_just_pressed("ability"):
			can_turn = false
			can_attack = false
			attack_finish_timer.start()
			attack_cooldown_timer.start()
			animation_tree.set("parameters/conditions/is_attacking", true)
		
		
	if input:	
		animation_tree.set("parameters/conditions/is_idle", false)
		animation_tree.set("parameters/conditions/is_moving", true)
		animation_tree.set("parameters/Idle/blend_position", input)
		animation_tree.set("parameters/Move/blend_position", input)
		
		var is_attacking = Input.is_action_pressed("ability") and right_state
		var should_flip = $Roomba/Sprite.flip_h and input.x > 0 or not $Roomba/Sprite.flip_h and input.x < 0
		if should_flip and not is_attacking:
			flip_sprites()
	else:
		animation_tree.set("parameters/conditions/is_idle", true)
		animation_tree.set("parameters/conditions/is_moving", false)

func flip_sprites():
	var opposite = not $Roomba/Sprite.flip_h
	$Roomba/Sprite.flip_h = opposite
	$Blender/Sprite.flip_h = opposite
	$Coffee/Sprite.flip_h = opposite
	$Refrigerator/Sprite.flip_h = opposite
	$Fan/Sprite.flip_h = opposite

func reset_sprite_flips():
	$Roomba/Sprite.flip_h = false
	$Blender/Sprite.flip_h = false
	$Coffee/Sprite.flip_h = false
	$Refrigerator/Sprite.flip_h = false
	$Fan/Sprite.flip_h = false

func change_state(state : State):
	
	# Disable the last state
	match current_state:
		State.UNASSIGNED:
			roomba.visible = false
			roomba.set_deferred("disabled", true)
		State.ROOMBA:
			roomba.visible = false
			roomba.set_deferred("disabled", true)
		State.BLENDER:
			blender.visible = false
			blender.set_deferred("disabled", true)
			MusicController.s_loop_blender()
		State.COFFEE:
			coffee.visible = false
			coffee.set_deferred("disabled", true)
		State.REFRIGERATOR:
			refrigerator.visible = false
			refrigerator.set_deferred("disabled", true)
		State.FAN:
			fan.visible = false
			fan.set_deferred("disabled", true)
	
	current_state = state
	
	# Enable the new state and change the appropriate stats
	match current_state:
		State.ROOMBA:
			roomba.visible = true
			roomba.set_deferred("disabled", false)
			
			speed = roomba_speed
			acceleration = roomba_acceleration
			deceleration = roomba_deceleration
		State.BLENDER:
			blender.visible = true
			blender.set_deferred("disabled", false)
			
			speed = blender_speed
			acceleration = blender_acceleration
			deceleration = blender_deceleration
		State.COFFEE:
			coffee.visible = true
			coffee.set_deferred("disabled", false)
			
			speed = coffee_speed
			acceleration = coffee_acceleration
			deceleration = coffee_deceleration
		State.REFRIGERATOR:
			refrigerator.visible = true
			refrigerator.set_deferred("disabled", false)
			
			speed = refrigerator_speed
			acceleration = refrigerator_acceleration
			deceleration = refrigerator_deceleration
		State.FAN:
			fan.visible = true
			fan.set_deferred("disabled", false)
			
			speed = fan_speed
			acceleration = fan_acceleration
			deceleration = fan_deceleration

func add_health(amount: float):
	if amount < 0:
		health += amount
		if is_alive:
			MusicController.p_hit()
		if health < 0:
			if is_alive:
				die()
				MusicController.p_game_over()
		else:
			check_for_state_change()
	else:
		health = min(max_health, health + amount)
		MusicController.p_pickup()
		check_for_state_change()
	
	hud.update_health_bar(health / max_health)

func die():
	is_alive = false
	hud.handle_death()
func check_for_state_change():
	
	if health >= 12:
		if current_state != State.FAN:
			if current_state < State.FAN:
				MusicController.p_transition_up()
			else:
				MusicController.p_transition_down()
			change_state(State.FAN)
	elif health >= 9:
		if current_state != State.REFRIGERATOR:
			if current_state < State.REFRIGERATOR:
				MusicController.p_transition_up()
			else:
				MusicController.p_transition_down()
			change_state(State.REFRIGERATOR)
	elif health >= 6:
		if current_state != State.COFFEE:
			if current_state < State.COFFEE:
				MusicController.p_transition_up()
			else:
				MusicController.p_transition_down()
			change_state(State.COFFEE)
	elif health >= 3:
		if current_state != State.BLENDER:
			if current_state < State.BLENDER:
				MusicController.p_transition_up()
			else:
				MusicController.p_transition_down()
			change_state(State.BLENDER)
	else:
		if current_state != State.ROOMBA:
			MusicController.p_transition_down()
			change_state(State.ROOMBA)

func _on_any_trigger_body_entered(body):
	if body is Enemy:
		hitlist.append(body)

func _on_any_trigger_body_exited(body):
	if body is Enemy:
		var id = hitlist.find(body)
		if id != -1:
			hitlist.remove_at(id)

func blender_behaviour(delta):
	if Input.is_action_just_pressed("ability"):
		MusicController.p_loop_blender()
	
	if Input.is_action_pressed("ability"):
		blender.get_node("AttackTrigger/CollisionShape2D").disabled = false
				
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
					
		blender.get_node("AttackTrigger").rotation_degrees = rotation_value
				
		# Deal damage to all enemies in the attack trrigger
		for hit in hitlist:
			
			if hit.has_method("get_hit"):
				hit.get_hit(blender_damage_per_second * delta)
				var new_acceleration = blender_knockback_max_speed / blender_knockback_time_to_max_velocity
				var final_vel = looking_dir * blender_knockback_max_speed * hit.knockback_multiplier
				hit.velocity = hit.velocity.move_toward(final_vel, new_acceleration * delta)
	
	if Input.is_action_just_released("ability"):
		blender.get_node("AttackTrigger/CollisionShape2D").disabled = true
		MusicController.s_loop_blender()

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
			var final_vel = looking_dir * fan_push_max_speed * hit.knockback_multiplier
			hit.velocity = hit.velocity.move_toward(final_vel, 
					new_acceleration * delta)
	
	if Input.is_action_just_released("ability"):
		fan.get_node("PushTrigger/CollisionShape2D").disabled = true


func _on_attack_cooldown_timeout():
	can_attack = true


func _on_attack_finish_timeout():
	can_turn = true
	animation_tree["parameters/playback"].travel("Idle")
	animation_tree.set("parameters/conditions/is_attacking", false)
	


func _on_footstep_timer_timeout():
	if input != Vector2.ZERO and is_alive:
		play_footstep()
		print("here")
	else:
		$FootstepTimer.stop()
