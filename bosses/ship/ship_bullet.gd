extends Bullet

var is_fired = false
var speed = 0
var direction

func _ready():
	GlobalBoss.connect("did_change_boss_state", self, "_boss_did_change")

func _process(delta):
	if is_fired:
		var dx = direction.x * speed * delta
		var dy = direction.y * speed * delta
		position += Vector2(dx, dy)

func fire(speed, direction):
	self.speed = speed
	self.direction = direction
	is_fired = true

func _on_Area2D_area_entered(area):
	_check_if_destroy(area)

func _on_Area2D_body_entered(body):
	_check_if_destroy(body)

func _check_if_destroy(object):
	if object.is_in_group("destroy_enemy_bullet") && !(object.is_in_group("is_invincible") || object.is_in_group("is_iframes")):
		if object.is_in_group("player"):
			GlobalPlayer.hit_by_enemy()
		destroy_bullet()

func _boss_did_change(state):
	queue_free()
