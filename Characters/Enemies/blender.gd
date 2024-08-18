class_name Blender
extends Enemy

@export var damage : int = 1

var is_player_here = false
var can_attack = true

@onready var cooldown_timer = $"Attack Cooldown"

func _on_attack_trigger_body_entered(body):
	if not can_attack: return
	
	is_player_here = true
	
	player.add_health(-damage)
	
	can_attack = false
	cooldown_timer.start()

func _on_attack_trigger_body_exited(body):
	is_player_here = false



func _on_attack_cooldown_timeout():
	if is_player_here:
		player.add_health(-damage)
		cooldown_timer.start()
	else:
		can_attack = true
