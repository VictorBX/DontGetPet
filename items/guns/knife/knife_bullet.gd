extends Bullet

const TIME_BEFORE_DISAPPEAR = 0.15
const SPEED = 180

var alive_timer
var direction
var connected = false

func _ready():
	alive_timer = Timer.new()
	alive_timer.one_shot = true
	alive_timer.connect("timeout", self, "_on_alive_finished")
	add_child(alive_timer)
	alive_timer.start(TIME_BEFORE_DISAPPEAR)

func configure(rotation, direction):
	self.rotation = rotation
	self.direction = direction

func _process(delta):
	position += direction * delta * SPEED

func _on_alive_finished():
	alive_timer.stop()
	if !connected:
		connected = true
		$AnimatedSprite.connect("animation_finished", self, "_on_animation_finished")
	$AnimatedSprite.play("disappear")

func _on_animation_finished():
	destroy_bullet()

func _on_Area2D_area_entered(area):
	check_if_destroy(area)

func _on_Area2D_body_entered(body):
	check_if_destroy(body)

func check_if_destroy(object):
	if object.is_in_group("boss"):
		GlobalBoss.hit_by_knife_bullet()
	if object.is_in_group("destroy_bullet"):
		_on_alive_finished()
