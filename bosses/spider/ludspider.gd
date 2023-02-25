extends KinematicBody2D

const CIRCLE_ATTACK = preload("res://bosses/spider/ludspider_circle_bullet.tscn")
const BOMB_GENERATOR = preload("res://bosses/ship/ship_bomb_generator.gd")
const LASER_PINCER = preload("res://bosses/spider/ludspider_laser_attack.tscn")

var is_halfway = false
var wait_timer
var attack_pattern = 0
var circle_attack_timer
var circles = 0
var bomb_timer
var bombs = 0
var is_dead = false

func _ready():
	GlobalBoss.connect("boss_did_die", self, "_on_boss_did_die")
	GlobalBoss.connect("is_halfway_third_phase", self, "_is_halfway_third_phase")
	circle_attack_timer = Timer.new()
	circle_attack_timer.connect("timeout", self, "_on_circle_attack_timeout")
	add_child(circle_attack_timer)
	bomb_timer = Timer.new()
	bomb_timer.connect("timeout", self, "_on_bomb_timeout")
	add_child(bomb_timer)
	
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	wait_timer.connect("timeout", self, "_on_wait_timer_timeout")
	add_child(wait_timer)
	_wait_for_next_attack(3)

func _on_boss_did_die():
	is_dead = true

func _is_halfway_third_phase():
	if is_halfway:
		return
	is_halfway = true

func _on_wait_timer_timeout():
#	if is_halfway:
#		_wait_for_next_attack(4)
#	else:
	if attack_pattern == 0:
		circles = 0
		_fire_circle_attack()
		circles += 1
		circle_attack_timer.start(1)
	elif attack_pattern == 1:
		bombs = 0
		_bomb_attack()
		bombs += 1
		bomb_timer.start(1)
	else:
		_laser_attack()
	attack_pattern += 1
	attack_pattern = attack_pattern % 3

func _wait_for_next_attack(time = 5):
	wait_timer.start(time)

# ATTACKS
func _on_circle_attack_timeout():
	_fire_circle_attack()
	if !circles == 5:
		circles += 1
	else:
		circle_attack_timer.stop()
		_wait_for_next_attack(3)

func _fire_circle_attack():
	if is_dead:
		return
	var attack = CIRCLE_ATTACK.instance()
	attack.global_position = global_position
	get_parent().add_child(attack)
	var direction = global_position.direction_to(get_parent().player_global_position())
	attack.fire(100, direction)

func _bomb_attack():
	if is_dead:
		return
	var bomb_targets = BOMB_GENERATOR.generate_bombs(get_parent().player_global_position(), 2)
	for bomb_target in bomb_targets:
		get_parent().add_child(bomb_target)
		bomb_target.configure(10, 30)

func _on_bomb_timeout():
	_bomb_attack()
	if !bombs == 2:
		bombs += 1
	else:
		bomb_timer.stop()
		_wait_for_next_attack(3)

func _laser_attack():
	if is_dead:
		return
	var laser = LASER_PINCER.instance()
	var angle = Vector2(1, 0).angle_to(get_parent().player_global_position())
	laser.connect("boss_laser_done", self, "_on_boss_laser_done")
	get_parent().add_child(laser)
	laser.configure(angle)

func _on_boss_laser_done():
	_wait_for_next_attack(3)
