extends Node2D

const GunType = preload("res://items/guns/gun_type.gd")
const MuzzleFlash = preload("res://items/guns/muzzle_flash.tscn")
const BulletDestroy = preload("res://items/guns/bullet_destroy.tscn")

const PolarStarBullet = preload("res://items/guns/polar_star/polar_star_bullet.tscn")
const Laser = preload("res://items/guns/laser/laser.tscn")
const KnifeBullet = preload("res://items/guns/knife/knife_bullet.tscn")

signal gun_position_update
signal did_create_bullet

var gun_type = -1
var laser = null
var gun_cooldown_timer
var can_shoot = true

func _ready():
	GlobalPlayer.connect("did_update_gun", self, "_did_update_gun")

func configure(gun_type):
	if self.gun_type == gun_type:
		return
	self.gun_type = gun_type
	match gun_type:
		GunType.GunType.GT_POLAR_STAR:
			$AnimatedSprite.play("polar_star_idle")
		GunType.GunType.GT_LASER:
			$AnimatedSprite.play("laser_idle")
		GunType.GunType.GT_KNIFE:
			$AnimatedSprite.play("knife_idle")

func fire(delta):
	if self.gun_type == GunType.GunType.GT_LASER:
		if laser == null && GlobalPlayer.can_shoot_laser():
			laser = Laser.instance()
			laser.position.x = 5
			add_child(laser)
			laser.fire()
		GlobalPlayer.reduce_laser_ammo(delta)
		return
	
	_create_muzzle_flash()
	_create_bullet(global_position)

func stop_firing():
	if self.gun_type == GunType.GunType.GT_LASER:
		if laser != null:
			laser.stop()
			laser.queue_free()
			laser = null

func _create_muzzle_flash():
	if !can_shoot:
		return
	if gun_type == GunType.GunType.GT_POLAR_STAR:
		var flash = MuzzleFlash.instance()
		flash.position = position
		flash.position.y = 0
		flash.position.x = 5
		add_child(flash)
		flash.configure(gun_type)
	
func _create_bullet(global_position):
	if !can_shoot:
		return
	
	if gun_type == GunType.GunType.GT_POLAR_STAR:
		var bullet = PolarStarBullet.instance()
		bullet.type = self.gun_type
		var direction = self.global_position.direction_to(get_global_mouse_position())
		bullet.global_position = global_position
		bullet.connect("bullet_destroyed", self, "_on_bullet_destroyed")
		bullet.configure(rotation, direction)
		$GunAudioStreamPlayer.play()
		emit_signal("did_create_bullet", bullet)
	elif gun_type == GunType.GunType.GT_KNIFE:
		var bullet = KnifeBullet.instance()
		bullet.type = self.gun_type
		var direction = self.global_position.direction_to(get_global_mouse_position())
		bullet.global_position = global_position
		bullet.configure(rotation, direction)
		$KnifeAudioStreamPlayer.play()
		emit_signal("did_create_bullet", bullet)
	
	can_shoot = false
	gun_cooldown_timer = Timer.new()
	gun_cooldown_timer.one_shot = true
	gun_cooldown_timer.connect("timeout", self, "_on_gun_cooldown_finished")
	add_child(gun_cooldown_timer)
	gun_cooldown_timer.start(GlobalPlayer.gun_cooldown())

func _on_bullet_destroyed(bullet):
	var bullet_destroy = BulletDestroy.instance()
	bullet_destroy.global_position = bullet.global_position
	bullet.get_parent().add_child(bullet_destroy)
	bullet_destroy.configure(bullet.type)

func point_gun_to_mouse(player_global_position):
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)
	$AnimatedSprite.flip_v = player_global_position.x > mouse_position.x
	emit_signal('gun_position_update')

func is_laser():
	return gun_type == GunType.GunType.GT_LASER

func _did_update_gun(gun):
	configure(gun)

func _on_gun_cooldown_finished():
	gun_cooldown_timer.queue_free()
	gun_cooldown_timer = null
	can_shoot = true
