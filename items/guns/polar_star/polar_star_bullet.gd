extends Bullet

const SPEED = 200
var direction

func _process(delta):
	position += direction * SPEED * delta

func configure(rotation, direction):
	self.rotation = rotation
	self.direction = direction

func _on_Area2D_body_entered(body):
	check_if_destroy(body)

func _on_Area2D_area_entered(area):
	check_if_destroy(area)

func check_if_destroy(object):
	if object.is_in_group("boss"):
		GlobalBoss.hit_by_polar_bullet()
	if object.is_in_group("destroy_bullet"):
		destroy_bullet()
