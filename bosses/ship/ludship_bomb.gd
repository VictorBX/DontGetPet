extends Node2D

var is_fired = false
var speed = 0
var direction

func _process(delta):
	if is_fired:
		var dx = direction.x * speed * delta
		var dy = direction.y * speed * delta
		position += Vector2(dx, dy)

func fire(speed, direction, rotation):
	self.rotation = rotation
	self.speed = speed
	self.direction = direction
	is_fired = true
