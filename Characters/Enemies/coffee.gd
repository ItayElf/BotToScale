extends Enemy

@export var projectile_speed := 300.0
@export var projectile_damage := 1
@export var follow_distance = 32.0

var current_offset : Vector2

@onready var animation_tree = $AnimationTree
@onready var projectile = preload("res://Objects/coffee_projectile.tscn")

func _process(delta):
	if current_target != null:	
		animation_tree.set("parameters/conditions/is_idle", false)
		animation_tree.set("parameters/conditions/is_moving", true)
		animation_tree.set("parameters/Idle/blend_position", input)
		animation_tree.set("parameters/Move/blend_position", input)
		
		if $Roomba/Sprite.flip_h and input.x > 0 or not $Roomba/Sprite.flip_h and input.x < 0:
			var opposite = not $Roomba/Sprite.flip_h
			$Roomba/Sprite.flip_h = opposite
			$Blender/Sprite.flip_h = opposite
			$Coffee/Sprite.flip_h = opposite
			$Refrigerator/Sprite.flip_h = opposite
			$Fan/Sprite.flip_h = opposite
		
	else:
		animation_tree.set("parameters/conditions/is_idle", true)
		animation_tree.set("parameters/conditions/is_moving", false)
		
		if not is_player_visible():
			current_target = player

func _on_coffee_cooldown_timeout():
	if player == null: 
		$Coffee/CoffeeCooldown.stop()
		return
	
	var direction = position.direction_to(player.position)
	
	if is_player_visible():
		var inst = projectile.instantiate()
		get_parent().add_child(inst)
		inst.global_position = global_position
		inst.initialize(false, projectile_speed, direction, projectile_damage)
		
		if position.distance_squared_to(player.position) < follow_distance * follow_distance:
			current_target = null
			print("null")
	

func is_player_visible():
	if player == null: return true
	var direction = position.direction_to(player.position)
	
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	var result = space_state.intersect_ray(query)
	
	return result and result["collider"] == player
