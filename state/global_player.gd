extends Node

const GunType = preload("res://items/guns/gun_type.gd")

const DASH_SPEED = 200
const DASH_COOLDOWN = 1.0
const MOVEMENT_SPEED = 100
const MAX_DISTANCE_BEFORE_COIN_MOVE_TOWARDS_PLAYER = 60

signal did_update_coins
signal did_update_health
signal did_update_gun
signal did_update_laser_ammo
signal did_die
signal did_reset_player
signal did_enable_laser
signal did_enable_sword
signal did_toggle_can_dash
signal player_was_hit

var can_player_do_anything = true
var health = 9
var coins = 0
var current_gun = GunType.GunType.GT_POLAR_STAR
var can_dash = true
var has_laser = false
var has_sword = false
var laser_ammo = 0
var has_increase_iframes = false
var has_faster_movement = false
var has_reduced_dash_cooldown = false
var has_reduced_gun_cooldown = false
var has_lucky_mans = false
var can_be_hit = true

func reset():
	self.coins = 0
	self.health = 9
	current_gun = GunType.GunType.GT_POLAR_STAR
	can_dash = true
	has_laser = false
	has_sword = false
	laser_ammo = 0
	has_increase_iframes = false
	has_faster_movement = false
	has_reduced_dash_cooldown = false
	has_reduced_gun_cooldown = false
	has_lucky_mans = false
	can_player_do_anything = true
	can_be_hit = true
	emit_signal("did_reset_player")

func hit_by_enemy():
	if can_be_hit:
		can_be_hit = false
		reduce_health()
		emit_signal("player_was_hit")

func done_with_iframes():
	can_be_hit = true

func reduce_health():
	health -= 1
	if health <= 0:
		emit_signal("did_die")
	else:
		emit_signal("did_update_health", health)

func increase_health():
	health += 1
	emit_signal("did_update_health", health)

func swap_gun():
	if self.current_gun == GunType.GunType.GT_POLAR_STAR:
		if has_sword:
			update_gun(GunType.GunType.GT_KNIFE)
		elif has_laser:
			update_gun(GunType.GunType.GT_LASER)
	elif self.current_gun == GunType.GunType.GT_KNIFE:
		if has_laser:
			update_gun(GunType.GunType.GT_LASER)
		else:
			update_gun(GunType.GunType.GT_POLAR_STAR)
	elif self.current_gun == GunType.GunType.GT_LASER:
		update_gun(GunType.GunType.GT_POLAR_STAR)

func update_gun(gun):
	if gun != self.current_gun:
		current_gun = gun
		emit_signal("did_update_gun", current_gun)

func reduce_coins(coins):
	self.coins -= coins
	emit_signal("did_update_coins", self.coins)

func update_coins(coins):
	if has_lucky_mans:
		self.coins += (coins * 2)
	else:
		self.coins += coins
	emit_signal("did_update_coins", self.coins)

func get_coins():
	return coins

func can_shoot_laser():
	return laser_ammo > 0
	
func reduce_laser_ammo(delta):
	laser_ammo -= (10 * delta)
	laser_ammo = max(0, laser_ammo)
	emit_signal("did_update_laser_ammo", laser_ammo)

func fill_laser_ammo():
	laser_ammo = 100
	emit_signal("did_update_laser_ammo", laser_ammo)

func get_laser_ammo():
	return laser_ammo

func enable_laser():
	if !has_laser:
		has_laser = true
		laser_ammo = 100
		emit_signal("did_enable_laser")

func enable_sword():
	if !has_sword:
		has_sword = true
		emit_signal("did_enable_sword")

func dash_speed():
	return 200

func iframes_time():
	if has_increase_iframes:
		return 10
	return 5

func dash_cooldown():
	if has_reduced_dash_cooldown:
		return 0.25
	return 0.5

func movement_speed():
	if has_faster_movement:
		return 130
	return 100

func gun_cooldown():
	if has_reduced_gun_cooldown:
		return 0.05
	return 0.1

func toggle_can_dash():
	can_dash = !can_dash
	emit_signal("did_toggle_can_dash", can_dash)

func max_distance_before_coin_moves_towards_player():
	if has_lucky_mans:
		return MAX_DISTANCE_BEFORE_COIN_MOVE_TOWARDS_PLAYER * 2
	else:
		return MAX_DISTANCE_BEFORE_COIN_MOVE_TOWARDS_PLAYER
