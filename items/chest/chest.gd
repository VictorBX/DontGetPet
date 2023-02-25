extends Node2D

const GUN_DAMAGE = 20
const KNIFE_DAMAGE = 100
const COIN = preload("res://items/chest/coin.tscn")
var health = 0
var coin_amount = 0
var value_per_coin = 0
var rare = 1

func configure(health, coin_amount, value_per_coin,rare):
	self.health = health
	self.coin_amount = coin_amount
	self.value_per_coin = value_per_coin
	
	if rare == 2:
		$Sprite.modulate.g = 0
	elif rare == 3:
		$Sprite.modulate.b = 0

func destroy():
	_generate_coins()
	queue_free()

func _on_Area2D_area_entered(area):
	if area.is_in_group("player_bullet"):
		if area.is_in_group("bullet_polar"):
			health -= GUN_DAMAGE
		elif area.is_in_group("bullet_knife"):
			health -= KNIFE_DAMAGE
		if health <= 0.0:
			destroy()

func _generate_coins():
	for i in coin_amount:
		var coin = COIN.instance()
		coin.value = value_per_coin
		coin.global_position = global_position
		get_parent().call_deferred("add_child", coin)
