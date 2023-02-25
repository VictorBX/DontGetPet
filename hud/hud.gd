extends Node2D

const GunType = preload("res://items/guns/gun_type.gd")
const PolarStarTexture = preload("res://assets/guns/polar_star/polar_star_idle.png")
const LaserTexture = preload("res://assets/guns/laser/laser_idle.png")
const KnifeTexture = preload("res://assets/guns/knife/knife_idle.png")

func _ready():
	GlobalPlayer.connect("did_reset_player", self, "_did_reset_player")
	GlobalPlayer.connect("did_update_coins", self, "_update_coins")
	GlobalPlayer.connect("did_update_gun", self, "_update_gun")
	GlobalPlayer.connect("did_update_health", self, "_update_health")
	GlobalPlayer.connect("did_update_laser_ammo", self, "_update_laser_ammo")
	GlobalPlayer.connect("did_enable_sword", self, "_did_enable_sword")
	GlobalPlayer.connect("did_enable_laser", self, "_did_enable_laser")
	GlobalPlayer.connect("did_toggle_can_dash", self, "_did_toggle_can_dash")
	_did_reset_player()

func reset():
	$GunSprite.texture = PolarStarTexture
	$KnifeSprite.texture = KnifeTexture
	$LaserSprite.texture = LaserTexture
	$KnifeSprite.hide()
	$LaserSprite.hide()
	$LaserLabel.hide()

func _update_health(health):
	$LivesLabel.text = "x%d" % health

func _did_reset_player():
	$CoinLabel.text = "0"
	$LivesLabel.text = "x9"
	$LaserLabel.text = "100%"
	$GunSprite.texture = PolarStarTexture
	$GunSprite.texture = PolarStarTexture
	$KnifeSprite.texture = KnifeTexture
	$LaserSprite.texture = LaserTexture
	$KnifeSprite.hide()
	$LaserSprite.hide()
	$LaserLabel.hide()

func _update_coins(coins):
	$CoinLabel.text = "%d" % coins

func _update_gun(gun):
	match gun:
		GunType.GunType.GT_POLAR_STAR:
			$HUDGunSelect.position = Vector2(69, 8)
		GunType.GunType.GT_LASER:
			$HUDGunSelect.position = Vector2(119, 8)
		GunType.GunType.GT_KNIFE:
			$HUDGunSelect.position = Vector2(94, 8)

func _update_laser_ammo(ammo):
	if GlobalPlayer.current_gun == GunType.GunType.GT_LASER:
		$LaserLabel.text = "%d%%" % GlobalPlayer.get_laser_ammo()

func _did_enable_sword():
	$KnifeSprite.show()

func _did_enable_laser():
	$LaserLabel.show()
	$LaserSprite.show()

func _did_toggle_can_dash(can_dash):
	if can_dash:
		$DashSprite.modulate.a = 1.0
	else:
		$DashSprite.modulate.a = 0.4
