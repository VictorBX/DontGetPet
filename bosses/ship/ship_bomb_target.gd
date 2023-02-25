extends Node2D

const Explosion = preload("res://bosses/ship/bomb_explosion.tscn")
const Bomb = preload("res://bosses/ship/ludship_bomb.tscn")

const EXPAND_TIME = 0.1
const EXPAND_ITERATIONS = 20
const BOMB_DISTANCE = 300
const BOMB_BUFFER = 10

var expand_timer
var start_radius
var end_radius
var current_radius
var current_iterations = 0
var delay_explosion_timer
var bomb
var exploded = false

func _ready():
	GlobalBoss.connect("did_change_boss_state", self, "_boss_did_change")
	expand_timer = Timer.new()
	expand_timer.connect("timeout", self, "_did_finish_expanding")
	add_child(expand_timer)
	
func configure(start_radius, end_radius):
	self.start_radius = start_radius
	self.end_radius = end_radius
	self.current_radius = start_radius
	$Target.update_target(current_radius)
	bomb = Bomb.instance()
	bomb.position = Vector2(0, -BOMB_DISTANCE)
	add_child(bomb)
	bomb.fire((BOMB_DISTANCE - BOMB_BUFFER)/_total_time(), Vector2(0, 1), 0)
	expand_timer.start(EXPAND_TIME)

func _did_finish_expanding():
	if exploded:
		return
	current_iterations += 1
	if current_iterations == EXPAND_ITERATIONS:
		exploded = true
		$Area2D/CollisionPolygon2D.polygon = $Target.get_polygon_points()
		$Area2D/CollisionPolygon2D.disabled = false
		delay_explosion_timer = Timer.new()
		delay_explosion_timer.one_shot = true
		delay_explosion_timer.connect("timeout", self, "_on_delay_explosion_timer")
		add_child(delay_explosion_timer)
		delay_explosion_timer.start(0.1)
	else:
		var update_amount = (end_radius - start_radius)/EXPAND_ITERATIONS
		self.current_radius += update_amount
		$Target.update_target(current_radius)

func _on_delay_explosion_timer():
	get_parent().screen_shake()
	bomb.queue_free()
	_create_explosion(Vector2(-15, -8))
	_create_explosion(Vector2(0, 8))
	_create_explosion(Vector2(15, -8))
	_create_explosion(Vector2(10, 8))
	_create_explosion(Vector2(10, -8))
	expand_timer.stop()
	expand_timer.queue_free()
	queue_free()

func _create_explosion(offset):
	var explosion = Explosion.instance()
	explosion.global_position = Vector2(global_position.x + offset.x, global_position.y + offset.y)
	get_parent().add_child(explosion)

func _total_time():
	return EXPAND_TIME * EXPAND_ITERATIONS

func _boss_did_change():
	queue_free()

func _on_Area2D_area_entered(area):
	_check_if_destroy(area)

func _on_Area2D_body_entered(body):
	_check_if_destroy(body)

func _check_if_destroy(object):
	if !(object.is_in_group("is_invincible") || object.is_in_group("is_iframes")):
		if object.is_in_group("player"):
			GlobalPlayer.hit_by_enemy()
