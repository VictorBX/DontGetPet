extends KinematicBody2D

const TIME_BETWEEN_ATTACKS = 5
const COIN = preload("res://items/chest/coin.tscn")
const BossSlash = preload("res://bosses/boss_slash.tscn")

signal ludbase_did_die

var is_dead = false
var dead_timer
var rng = RandomNumberGenerator.new()

var particles_timer
var delay_position
var wait_timer
var current_attack = -1

const CIRCULAR_SLASHES_FOR_CIRCLE = 15
var circular_slashes = 0
var circular_timer
var circular_last_angle

const FC_POS = 180
var fc_corner = 0
var fc_timer

func _ready():
	rng.randomize()
	GlobalBoss.connect("did_change_boss_state", self, "_did_change_boss_state")
	$BossSpeech.connect("did_finish_speech", self, "_did_finish_speech")
	particles_timer = Timer.new()
	particles_timer.one_shot = true
	particles_timer.connect("timeout", self, "_on_particles_done")
	add_child(particles_timer)
	wait_timer = Timer.new()
	wait_timer.one_shot = true
	wait_timer.connect("timeout", self, "_on_attack_wait_done")
	add_child(wait_timer)

func _did_finish_speech():
	GlobalBoss.finish_speech()
	attack()

func start_speech():
	$BossSpeech.start()

func _did_change_boss_state(state):
	if is_dead:
		return
	is_dead = true
	$AnimatedSprite.play("dead")
	_generate_coins()
	dead_timer = Timer.new()
	dead_timer.one_shot = true
	dead_timer.connect("timeout", self, "_dead_timer_timeout")
	add_child(dead_timer)
	dead_timer.start(5)

func _generate_coins():
	var coin_amount = rng.randi_range(50, 100)
	for i in coin_amount:
		var coin = COIN.instance()
		coin.value = 5
		coin.global_position = global_position
		get_parent().call_deferred('add_child', coin)

func _dead_timer_timeout():
	$AnimatedSprite.play("default")
	$AnimationPlayer.play("disappear")
	$CollisionShape2D.disabled = true
	var end_timer = Timer.new()
	end_timer.one_shot = true
	end_timer.connect("timeout", self, "_on_end_timer_timeout")
	add_child(end_timer)
	end_timer.start(4.0)
	
func _on_end_timer_timeout():
	emit_signal("ludbase_did_die")
	queue_free()

# ATTACKS
func attack():
	if is_dead:
		return
	$AnimatedSprite.play("default")
	current_attack += 1
	current_attack = current_attack % 2
	wait_timer.start(TIME_BETWEEN_ATTACKS)

func _on_attack_wait_done():
	if current_attack == 0:
		_circular_slash_pattern()
	elif current_attack == 1:
		four_corner_attack()
	
func move_lud(position):
	delay_position = position
	$AnimatedSprite.play("default")
	$AnimatedSprite.hide()
	$CPUParticles2D.emitting = true
	particles_timer.start(0.4)

func _on_particles_done():
	self.position = delay_position
	$AnimatedSprite.show()

# CIRCULAR PATTERN
func _circular_slash_pattern():
	if is_dead:
		return
	circular_slashes = 0
	circular_last_angle = 0
	if global_position != Vector2(0,0):
		move_lud(Vector2(0,0))
	$AnimatedSprite.play("luddy")
	_fire_circular_slash()
	circular_timer = Timer.new()
	circular_timer.connect("timeout", self, "_fire_circular_slash")
	add_child(circular_timer)
	circular_timer.start(0.2)

func _fire_circular_slash():
	if is_dead:
		return
	var slash = BossSlash.instance()
	var direction = Vector2(
		1 * cos(circular_last_angle),
		1 * sin(circular_last_angle)
	)
	var rotation = Vector2(1, 0).angle_to(direction)
	slash.configure(rotation, direction)
	get_parent().add_child(slash)
	
	circular_last_angle += 360/CIRCULAR_SLASHES_FOR_CIRCLE
	circular_slashes += 1
	if circular_slashes >= _amount_of_circular_slashes():
		circular_timer.stop()
		circular_timer.queue_free()
		circular_timer = null
		attack()

func _amount_of_circular_slashes():
	return 30

# FOUR CORNER
func four_corner_attack():
	if is_dead:
		return
	fc_corner = 0
	$AnimatedSprite.play("luddy")
	move_lud(Vector2(FC_POS, -FC_POS))
	_fire_fc_slashes(Vector2(FC_POS, -FC_POS))
	fc_timer = Timer.new()
	fc_timer.connect("timeout", self, "_fc_timer_timeout")
	add_child(fc_timer)
	fc_timer.start(1)

func _fc_timer_timeout():
	fc_corner += 1
	if fc_corner >= 4:
		fc_timer.stop()
		fc_timer.queue_free()
		fc_timer = null
		attack()
		return
	
	if fc_corner == 1:
		move_lud(Vector2(-FC_POS, FC_POS))
		_fire_fc_slashes(Vector2(-100, 100))
	if fc_corner == 2:
		move_lud(Vector2(-FC_POS, -FC_POS))
		_fire_fc_slashes(Vector2(-FC_POS, -FC_POS))
	if fc_corner == 3:
		move_lud(Vector2(FC_POS, FC_POS))
		_fire_fc_slashes(Vector2(FC_POS, FC_POS))

func _fire_fc_slashes(lud_pos):
	if is_dead:
		return
	var slash_1 = BossSlash.instance()
	var slash_2 = BossSlash.instance()
	var slash_3 = BossSlash.instance()
	
	var s1_pos = lud_pos
	var s2_pos = lud_pos + (32 * _s1_pos_for_corner())
	var s3_pos = lud_pos + (32 * _s2_pos_for_corner())
	
	var direction = s1_pos.direction_to(get_parent().player_global_position())
	var rotation = Vector2(1, 0).angle_to(direction)
	slash_1.configure(rotation, direction)
	slash_1.global_position = lud_pos
	get_parent().add_child(slash_1)
	
	direction = s2_pos.direction_to(get_parent().player_global_position())
	rotation = Vector2(1, 0).angle_to(direction)
	slash_2.configure(rotation, direction)
	slash_2.global_position = lud_pos
	get_parent().add_child(slash_2)
	
	direction = s3_pos.direction_to(get_parent().player_global_position())
	rotation = Vector2(1, 0).angle_to(direction)
	slash_3.configure(rotation, direction)
	slash_3.global_position = lud_pos
	get_parent().add_child(slash_3)

func _s1_pos_for_corner():
	if fc_corner == 0 || fc_corner ==  3:
		return Vector2(-1, 0)
	if fc_corner == 1 || fc_corner == 2:
		return Vector2(1, 0)

func _s2_pos_for_corner():
	if fc_corner == 0 || fc_corner ==  3:
		return Vector2(0, 1)
	if fc_corner == 1 || fc_corner == 2:
		return Vector2(0, -1)
