extends Node

const ShopItemType = preload("res://hud/shop_item_type.gd")

signal reduce_coins_by_amount

var bought_laser = false
var bought_sword = false
var bought_increase_iframes = false
var bought_faster_movement = false
var bought_less_dash_cooldown = false
var bought_less_gun_cooldown = false
var bought_lucky_mans = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset():
	bought_laser = false
	bought_sword = false
	bought_increase_iframes = false
	bought_faster_movement = false
	bought_less_dash_cooldown = false
	bought_less_gun_cooldown = false
	bought_lucky_mans = false

func cost_for_item(shop_item_type):
	match shop_item_type:
		ShopItemType.ShopItemType.SI_LASER:
			return 2000
		ShopItemType.ShopItemType.SI_SWORD:
			return 1000
		ShopItemType.ShopItemType.SI_QT_BLESSING:
			return 500
		ShopItemType.ShopItemType.SI_LASER_JUICE:
			return 500
		ShopItemType.ShopItemType.SI_INCREASE_IFRAMES:
			return 500
		ShopItemType.ShopItemType.SI_FASTER_MOVEMENT:
			return 500
		ShopItemType.ShopItemType.SI_REDUCE_DASH_COOLDOWN:
			return 500
		ShopItemType.ShopItemType.SI_REDUCE_GUN_COOLDOWN:
			return 250
		ShopItemType.ShopItemType.SI_LUCKY_MANS:
			return 2000

func can_purchase_item(shop_item_type):
	var cost = cost_for_item(shop_item_type)
	return cost < GlobalPlayer.get_coins()

func purchase_item(shop_item_type):
	var cost = cost_for_item(shop_item_type)
	if cost < GlobalPlayer.get_coins():
		match shop_item_type:
			ShopItemType.ShopItemType.SI_LASER:
				bought_laser = true
				GlobalPlayer.enable_laser()
			ShopItemType.ShopItemType.SI_SWORD:
				bought_sword = true
				GlobalPlayer.enable_sword()
			ShopItemType.ShopItemType.SI_QT_BLESSING:
				GlobalPlayer.increase_health()
			ShopItemType.ShopItemType.SI_LASER_JUICE:
				GlobalPlayer.fill_laser_ammo()
			ShopItemType.ShopItemType.SI_INCREASE_IFRAMES:
				bought_increase_iframes = true
				GlobalPlayer.has_increase_iframes = true
			ShopItemType.ShopItemType.SI_FASTER_MOVEMENT:
				bought_faster_movement = true
				GlobalPlayer.has_faster_movement = true
			ShopItemType.ShopItemType.SI_REDUCE_DASH_COOLDOWN:
				bought_less_dash_cooldown = true
				GlobalPlayer.has_reduced_dash_cooldown = true
			ShopItemType.ShopItemType.SI_REDUCE_GUN_COOLDOWN:
				bought_less_gun_cooldown = true
				GlobalPlayer.has_reduced_gun_cooldown = true
			ShopItemType.ShopItemType.SI_LUCKY_MANS:
				bought_lucky_mans = true
				GlobalPlayer.has_lucky_mans = true
		GlobalPlayer.reduce_coins(cost)

func is_one_time_purchase(shop_item_type):
	if shop_item_type == ShopItemType.ShopItemType.SI_LASER_JUICE || shop_item_type == ShopItemType.ShopItemType.SI_QT_BLESSING:
		return false
	else:
		return true

func has_purchased_one_time_item(shop_item_type):
	if shop_item_type == ShopItemType.ShopItemType.SI_LASER_JUICE || shop_item_type == ShopItemType.ShopItemType.SI_QT_BLESSING:
		return false
	else:
		match shop_item_type:
			ShopItemType.ShopItemType.SI_LASER:
				return bought_laser
			ShopItemType.ShopItemType.SI_SWORD:
				return bought_sword
			ShopItemType.ShopItemType.SI_INCREASE_IFRAMES:
				return bought_increase_iframes
			ShopItemType.ShopItemType.SI_FASTER_MOVEMENT:
				return bought_faster_movement
			ShopItemType.ShopItemType.SI_REDUCE_DASH_COOLDOWN:
				return bought_less_dash_cooldown
			ShopItemType.ShopItemType.SI_REDUCE_GUN_COOLDOWN:
				return bought_less_gun_cooldown
			ShopItemType.ShopItemType.SI_LUCKY_MANS:
				return bought_lucky_mans
	
