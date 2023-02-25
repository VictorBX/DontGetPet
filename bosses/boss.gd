extends KinematicBody2D
class_name Boss 

signal boss_did_die
var health

func take_damage(damage):
	health -= damage
	if health <= 0:
		emit_signal("boss_did_die")
