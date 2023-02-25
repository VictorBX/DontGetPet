extends KinematicBody2D

enum PlayerState {PS_IDLE, PS_RUNNING, PS_DASHING, PS_DYING}
enum PlayerDirection {PD_LEFT, PD_RIGHT}

const GunType = preload("res://items/guns/gun_type.gd")
const DASH_TIME = 0.3
const DASH_GHOST_TIME = 0.05
const GUN_POSITION = 6

var state = PlayerState.PS_IDLE
var player_direction = PlayerDirection.PD_LEFT

# dashing
var dash_ghost = preload("res://player/player_ghost.tscn")
var dash_direction = Vector2(0, 0)
var dash_timer
var dash_cooldown_timer
var dash_ghost_timer
var can_dash = true

# gun
var Gun = preload("res://items/guns/gun.tscn")
var current_gun
var muzzle_flash_timer

#iframes
var is_hit = false
var iframes_timer
var hit_blink_timer
var hit_blink_state = 0

func _ready():
	_change_state(PlayerState.PS_IDLE)
	$Gun.configure(GunType.GunType.GT_POLAR_STAR)
	$Gun.connect("gun_position_update", self, "_gun_position_update")
	$Gun.connect("did_create_bullet", self, "_gun_did_create_bullet")
	GlobalPlayer.connect("did_update_laser_ammo", self, "_did_update_laser_ammo")
	GlobalPlayer.connect("player_was_hit", self, "_player_was_hit")

func _process(delta):
	if !GlobalPlayer.can_player_do_anything:
		return
	if self.state != PlayerState.PS_DYING:
		if self.state == PlayerState.PS_DASHING:
			# dashing
			_process_dashing(delta)
		else:
			# moving or idle
			_process_movement(delta)
			_process_gun(delta)

func _process_gun(delta):
	$Gun.point_gun_to_mouse(global_position)
	
	if Input.is_action_just_released("ui_select"):
		GlobalPlayer.swap_gun()
	
	if Input.is_action_just_pressed("ui_fire_1") && !$Gun.is_laser():
		_display_muzzle_flash()
		$Gun.fire(delta)
	
	if Input.is_action_pressed("ui_fire_1") && $Gun.is_laser():
		$Gun.fire(delta)
	
	if Input.is_action_just_released("ui_fire_1") && $Gun.is_laser():
		$Gun.stop_firing()

func _process_movement(delta):
	var dx = 0.0
	var dy = 0.0
	var speed = GlobalPlayer.movement_speed()
	if Input.is_action_pressed("ui_up"):
		dy -= speed
	if Input.is_action_pressed("ui_down"):
		dy += speed
	if Input.is_action_pressed("ui_left"):
		dx -= speed
	if Input.is_action_pressed("ui_right"):
		dx += speed
	
	if dx == 0 && dy == 0:
		_change_state(PlayerState.PS_IDLE)
	else:
		_change_state(PlayerState.PS_RUNNING)
		if dx < 0:
			_change_player_direction(PlayerDirection.PD_LEFT)
		elif dx > 0:
			_change_player_direction(PlayerDirection.PD_RIGHT)
	
	if Input.is_action_just_pressed("ui_fire_2") && can_dash:
		# dashing just started
		can_dash = false
		dash_direction = Vector2(sign(dx), sign(dy))
		_change_state(PlayerState.PS_DASHING)
		dash_ghost_timer = Timer.new()
		dash_ghost_timer.connect("timeout", self, "_create_dash_ghost")
		add_child(dash_ghost_timer)
		dash_ghost_timer.start(DASH_GHOST_TIME)
		dash_timer = Timer.new()
		dash_timer.one_shot = true
		dash_timer.connect("timeout", self, "_dash_did_finish")
		add_child(dash_timer)
		dash_timer.start(DASH_TIME)
	else:
		move_and_slide(Vector2(dx, dy))

func _process_dashing(delta):
	var dx = 0
	var dy = 0
	var dash_speed = GlobalPlayer.dash_speed()
	if dash_direction.x == 0 && dash_direction.y == 0:
		if player_direction == PlayerDirection.PD_LEFT:
			dx = -1 * dash_speed
		else:
			dx = 1 * dash_speed
	else:
		dx = dash_direction.x * dash_speed
		dy = dash_direction.y * dash_speed
	move_and_slide(Vector2(dx, dy))

func _dash_did_finish():
	_change_state(PlayerState.PS_IDLE)
	dash_timer.queue_free()
	dash_timer = null
	dash_ghost_timer.queue_free()
	dash_ghost_timer = null
	dash_cooldown_timer = Timer.new()
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.connect("timeout", self, "_dash_cooldown_did_finish")
	add_child(dash_cooldown_timer)
	dash_cooldown_timer.start(GlobalPlayer.dash_cooldown())

func _dash_cooldown_did_finish():
	dash_cooldown_timer.queue_free()
	dash_cooldown_timer = null
	GlobalPlayer.toggle_can_dash()
	can_dash = true

func _create_dash_ghost():
	var ghost: Sprite = dash_ghost.instance()
	ghost.global_position = global_position
	ghost.texture = $AnimatedSprite.frames.get_frame($AnimatedSprite.animation, $AnimatedSprite.frame)
#	ghost.frame = $AnimatedSprite.frame
	ghost.flip_h = $AnimatedSprite.flip_h
	ghost.z_index = z_index - 1
	get_parent().add_child(ghost)

func _change_state(state):
	if self.state == state:
		return
	var previous_state = self.state
	self.state = state
	match state:
		PlayerState.PS_IDLE:
			_remove_invincible_group()
			$AnimatedSprite.play("idle")
		PlayerState.PS_RUNNING:
			_remove_invincible_group()
			$AnimatedSprite.play("walk_left")
		PlayerState.PS_DASHING:
			GlobalPlayer.toggle_can_dash()
			$DamageArea2D.add_to_group("is_invincible")
		PlayerState.PS_DYING:
			_remove_invincible_group()

func _remove_invincible_group():
	if $DamageArea2D.is_in_group("is_invincible"):
		$DamageArea2D.remove_from_group("is_invincible")

func _change_player_direction(player_direction):
	if self.player_direction == player_direction:
		return
	self.player_direction = player_direction
	$AnimatedSprite.flip_h = player_direction == PlayerDirection.PD_RIGHT

func _gun_position_update():
	var mouse_x = floor(get_global_mouse_position().x)
	var xdiff = -1 * (floor(global_position.x) - mouse_x)
	var gunx = max(min(xdiff, GUN_POSITION), -GUN_POSITION)
	$Gun.position.x = gunx

func _gun_did_create_bullet(bullet):
	get_parent().add_child(bullet)

func _display_muzzle_flash():
	if !$Gun.can_shoot:
		return
	var rotation = 0
	if player_direction == PlayerDirection.PD_LEFT:
		rotation = -$Gun.rotation
	else:
		rotation = $Gun.rotation + PI
	$AnimatedSprite.material.set_shader_param('gun_rotation', rotation);
	$AnimatedSprite.material.set_shader_param('is_muzzle_flash_on', true);
	muzzle_flash_timer = Timer.new()
	muzzle_flash_timer.one_shot = true
	muzzle_flash_timer.connect("timeout", self, "_on_muzzle_flash_finished")
	add_child(muzzle_flash_timer)
	muzzle_flash_timer.start(0.1)

func _on_muzzle_flash_finished():
	$AnimatedSprite.material.set_shader_param('is_muzzle_flash_on', false);
	muzzle_flash_timer.queue_free()
	muzzle_flash_timer = null

func _did_update_laser_ammo(ammo):
	if ammo <= 0:
		$Gun.stop_firing()

#IFRAMES
func _player_was_hit():
	$HurtAudioStreamPlayer.play()
	$DamageArea2D.add_to_group("is_iframes")
	iframes_timer = Timer.new()
	iframes_timer.connect("timeout", self, "_on_iframes_timeout")
	iframes_timer.one_shot = true
	add_child(iframes_timer)
	hit_blink_timer = Timer.new()
	hit_blink_timer.connect("timeout", self, "_on_hit_blink_timeout")
	add_child(hit_blink_timer)	
	iframes_timer.start(GlobalPlayer.iframes_time())
	hit_blink_timer.start(0.15)

func _on_iframes_timeout():
	hit_blink_timer.stop()
	hit_blink_timer.queue_free()
	iframes_timer.queue_free()
	if $DamageArea2D.is_in_group("is_iframes"):
		$DamageArea2D.remove_from_group("is_iframes")
	$AnimatedSprite.modulate.a = 1
	GlobalPlayer.done_with_iframes()

func _on_hit_blink_timeout():
	if hit_blink_state == 0:
		$AnimatedSprite.modulate.a = 0.3
	else:
		$AnimatedSprite.modulate.a = 0.8
	hit_blink_state += 1
	hit_blink_state = hit_blink_state % 2
