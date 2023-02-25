extends Boss

const PULSE_AMOUNT = 60
const PULSE_RADIUS = 5
const BULLET_SPEED = 100
const SHIP_BULLET_DESTROY = preload("res://bosses/boss_bullet_destroy.tscn")
const SHIP_BULLET = preload("res://bosses/ship/ship_bullet.tscn")
const BOSS_GUN_TYPE = preload("res://bosses/boss_gun_type.gd")
const BOMB_GENERATOR = preload("res://bosses/ship/ship_bomb_generator.gd")
const Explosion = preload("res://bosses/ship/bomb_explosion.tscn")
const COIN = preload("res://items/chest/coin.tscn")

signal ludship_did_die

var is_dead = false
var rng = RandomNumberGenerator.new()

var is_halfway = false
var wait_timer
var pulse_times = 0
var pulse_pattern_timer
var attack_pattern = 0

func _ready():
	rng.randomize()
	GlobalBoss.connect("is_halfway_second_phase", self, "_is_halfway_second_phase")
	GlobalBoss.connect("did_change_boss_state", self, "_did_change_boss_state")
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	wait_timer.connect("timeout", self, "_on_wait_timer_timeout")
	add_child(wait_timer)
	_wait_for_next_attack(3)
	
	pulse_pattern_timer = Timer.new()
	pulse_pattern_timer.connect("timeout", self, "_on_pulse_pattern_timer_timeout")
	add_child(pulse_pattern_timer)

func _is_halfway_second_phase():
	if is_halfway:
		return
	is_halfway = true

func _on_wait_timer_timeout():
	if is_halfway:
		_bomb_attack()
		_pulse_attack()
		_wait_for_next_attack(4)
	else:
		if attack_pattern == 0:
			_bomb_attack()
		else:
			pulse_times = 0
			_pulse_attack()
			pulse_times += 1
			pulse_pattern_timer.start(1.5)
		attack_pattern += 1
		attack_pattern = attack_pattern % 2

func _on_pulse_pattern_timer_timeout():
	_pulse_attack()
	if !pulse_times == 3:
		pulse_times += 1
	else:
		pulse_pattern_timer.stop()
		_wait_for_next_attack(4)

func _pulse_attack():
	if is_dead:
		return
	var degree_amount = 360.0/PULSE_AMOUNT
	for i in PULSE_AMOUNT:
		var bullet = SHIP_BULLET.instance()
		var degrees = deg2rad(degree_amount * i)
		var initial_position = Vector2(
			PULSE_RADIUS * cos(degrees),
			PULSE_RADIUS * sin(degrees)
		)
		bullet.type = BOSS_GUN_TYPE.BossGunType.BGT_SMALL_RED
		bullet.position = Vector2(
			global_position.x + initial_position.x,
			global_position.y + initial_position.y
		)
		bullet.connect("bullet_destroyed", self, "_on_bullet_destroyed")
		get_parent().add_child(bullet)
		bullet.fire(BULLET_SPEED, initial_position.normalized())

func _bomb_attack():
	if is_dead:
		return
	var bomb_targets = BOMB_GENERATOR.generate_bombs(get_parent().player_global_position(), 2)
	for bomb_target in bomb_targets:
		get_parent().add_child(bomb_target)
		bomb_target.configure(10, 30)
	if !is_halfway:
		_wait_for_next_attack(3)

func _on_bullet_destroyed(bullet):
	var bullet_destroy = SHIP_BULLET_DESTROY.instance()
	bullet_destroy.global_position = bullet.global_position
	bullet.get_parent().add_child(bullet_destroy)
	bullet_destroy.configure(bullet.type)

func _did_change_boss_state(state):
	if is_dead:
		return
	is_dead = true
	_generate_coins()
	_create_explosition(Vector2(global_position.x - 10, global_position.y - 8))
	_create_explosition(Vector2(global_position.x, global_position.y))
	_create_explosition(Vector2(global_position.x + 10, global_position.y - 8))
	get_parent().screen_shake()
	$CollisionShape2D.disabled = true
	$BulletArea2D/CollisionPolygon2D.disabled = true
	hide()
	
	var end_timer = Timer.new()
	end_timer.one_shot = true
	end_timer.connect("timeout", self, "_on_end_timer_timeout")
	add_child(end_timer)
	end_timer.start(4.0)

func _generate_coins():
	var coin_amount = rng.randi_range(75, 100)
	for i in coin_amount:
		var coin = COIN.instance()
		coin.value = 20
		coin.global_position = global_position
		get_parent().call_deferred("add_child", coin)

func _create_explosition(gposition):
	var explosion = Explosion.instance()
	explosion.global_position = gposition
	get_parent().add_child(explosion)

func _on_end_timer_timeout():
	emit_signal("ludship_did_die")
	queue_free()

func _wait_for_next_attack(time = 5):
	wait_timer.start(time)
