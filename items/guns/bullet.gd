extends Node2D
class_name Bullet 

signal bullet_destroyed
var damage = 0
var type

func destroy_bullet():
	emit_signal("bullet_destroyed", self)
	queue_free()
