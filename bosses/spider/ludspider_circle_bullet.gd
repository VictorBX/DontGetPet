extends Node2D

const BOUNDS = 300
var is_fired = false
var speed = 0
var direction

func _ready():
	GlobalBoss.connect("did_change_boss_state", self, "_boss_did_change")
	GlobalBoss.connect("boss_did_die", self, "_boss_did_change")

func _process(delta):
	if is_fired:
		rotation_degrees += 15 * delta
		var dx = direction.x * speed * delta
		var dy = direction.y * speed * delta
		position += Vector2(dx, dy)
		if (position.x >= BOUNDS || position.x <= -BOUNDS) || (position.y >= BOUNDS || position.y <= -BOUNDS):
			queue_free()

func fire(speed, direction):
	self.speed = speed
	self.direction = direction
	is_fired = true

func _boss_did_change():
	queue_free()
