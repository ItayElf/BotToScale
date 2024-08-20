extends Enemy

@export var freeze_multiplier = 0.5
@export var damage = 2

var can_attack = true
var can_turn = true

@onready var animation_tree = $AnimationTree
@onready var attack_finish_timer = $Refrigerator/AttackFinish
@onready var attack_cooldown_timer = $Refrigerator/AttackCooldown

func _process(delta):
	if current_target != null:
		if can_turn:	
			animation_tree.set("parameters/conditions/is_idle", false)
			animation_tree.set("parameters/conditions/is_moving", true)
			animation_tree.set("parameters/Idle/blend_position", input)
			animation_tree.set("parameters/Move/blend_position", input)
			animation_tree.set("parameters/Ability/blend_position", input)
			
			if $Roomba/Sprite.flip_h and input.x > 0 or not $Roomba/Sprite.flip_h and input.x < 0:
				var opposite = not $Roomba/Sprite.flip_h
				$Roomba/Sprite.flip_h = opposite
				$Blender/Sprite.flip_h = opposite
				$Coffee/Sprite.flip_h = opposite
				$Refrigerator/Sprite.flip_h = opposite
				$Fan/Sprite.flip_h = opposite
				
				$Refrigerator/AttackTrigger.scale.y *= -1
				$Refrigerator/AttackTrigger.rotation_degrees += 180.0
	else:
		animation_tree.set("parameters/conditions/is_idle", true)
		animation_tree.set("parameters/conditions/is_moving", false)

func _on_freeze_trigger_body_entered(body):
	if body is Player:
		body.speed_multiplier = freeze_multiplier
		body.fridge_counter += 1
	elif body is Enemy:
		body.slowed_down_multiplier = min(body.slowed_down_multiplier, freeze_multiplier)
		body.fridge_counter += 1


func _on_freeze_trigger_body_exited(body):
	if body is Player:
		body.fridge_counter -= 1
		if body.fridge_counter <= 0:
			body.speed_multiplier = 1.0
	elif body is Enemy:
		body.fridge_counter -= 1
		
		if body.fridge_counter <= 0:
			body.slowed_down_multiplier = 1.0


func _on_new_attack_trigger_body_entered(body):
	if can_attack:
		body.add_health(-damage)
		can_turn = false
		can_attack = false
		attack_finish_timer.start()
		attack_cooldown_timer.start()
		animation_tree.set("parameters/conditions/is_attacking", true)
		MusicController.p_fridge_footstep()


func _on_attack_finish_timeout():
	can_turn = true
	animation_tree["parameters/playback"].travel("Idle")
	animation_tree.set("parameters/conditions/is_attacking", false)


func _on_attack_cooldown_timeout():
	can_attack = true
