class_name Blender
extends Enemy

@export var damage : int = 1

var is_player_here = false
var can_attack = true

@onready var cooldown_timer = $"Attack Cooldown"
@onready var animation_tree = $AnimationTree

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

func _on_attack_trigger_body_entered(body):
	if not can_attack: return
	
	is_player_here = true
	
	attack()

func _on_attack_trigger_body_exited(body):
	is_player_here = false

func attack():
	player.add_health(-damage)
	can_attack = false
	cooldown_timer.start()
	MusicController.p_attack_slice()

func _on_attack_cooldown_timeout():
	if is_player_here:
		attack()
	else:
		can_attack = true
