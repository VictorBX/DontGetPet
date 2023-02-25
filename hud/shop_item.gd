extends Button

const ShopItemType = preload("res://hud/shop_item_type.gd")
const LaserIcon = preload("res://assets/guns/laser/laser_idle.png")
const KnifeIcon = preload("res://assets/guns/knife/knife_idle.png")
const QTIcon = preload("res://assets/hud/qts_blessing.png")
const LaserJuiceIcon = preload("res://assets/hud/laser_juice.png")
const IncreaseIframesIcon = preload("res://assets/hud/increase_iframes.png")
const ReduceDashIcon = preload("res://assets/hud/reduce_dash.png")
const ReduceGunIcon = preload("res://assets/hud/reduce_gun.png")
const FasterMovementIcon = preload("res://assets/hud/faster_movement.png")
const LuckyMansIcon = preload("res://assets/hud/lucky_mans.png")

signal did_highlight_item

var shop_item_type
var is_purchased

func configure(shop_item_type):
	self.is_purchased = GlobalShop.has_purchased_one_time_item(shop_item_type)
	self.shop_item_type = shop_item_type
	if is_purchased:
		$SoldRichTextLabel.show()
		$Sprite.modulate.a = 0.5
	else:
		$SoldRichTextLabel.hide()
		$Sprite.modulate.a = 1.0
	$Sprite.offset.x = 0
	match shop_item_type:
		ShopItemType.ShopItemType.SI_LASER:
			$Sprite.texture = LaserIcon
		ShopItemType.ShopItemType.SI_SWORD:
			$Sprite.offset.x = -3
			$Sprite.texture = KnifeIcon
		ShopItemType.ShopItemType.SI_QT_BLESSING:
			$Sprite.texture = QTIcon
		ShopItemType.ShopItemType.SI_LASER_JUICE:
			$Sprite.texture = LaserJuiceIcon
		ShopItemType.ShopItemType.SI_INCREASE_IFRAMES:
			$Sprite.texture = IncreaseIframesIcon
		ShopItemType.ShopItemType.SI_REDUCE_DASH_COOLDOWN:
			$Sprite.texture = ReduceDashIcon
		ShopItemType.ShopItemType.SI_REDUCE_GUN_COOLDOWN:
			$Sprite.texture = ReduceGunIcon
		ShopItemType.ShopItemType.SI_FASTER_MOVEMENT:
			$Sprite.texture = FasterMovementIcon
		ShopItemType.ShopItemType.SI_LUCKY_MANS:
			$Sprite.texture = LuckyMansIcon

func is_highlighted(highlighted):
	var alpha = 0.6
	if highlighted:
		alpha = 1.0
	$TLDColorRect.modulate.a = alpha
	$TLRColorRect.modulate.a = alpha
	$BRUColorRect.modulate.a = alpha
	$BRLColorRect.modulate.a = alpha
	emit_signal("did_highlight_item", highlighted, shop_item_type)

func _on_ShopItem_mouse_entered():
	is_highlighted(true)

func _on_ShopItem_mouse_exited():
	is_highlighted(false)

func _on_ShopItem_pressed():
	var is_one_time_purchase = GlobalShop.has_purchased_one_time_item(shop_item_type)
	if GlobalShop.can_purchase_item(shop_item_type) && !is_one_time_purchase:
		GlobalShop.purchase_item(shop_item_type)
		self.is_purchased = GlobalShop.has_purchased_one_time_item(shop_item_type)
		if is_purchased:
			$SoldRichTextLabel.show()
			$Sprite.modulate.a = 0.5
		else:
			$SoldRichTextLabel.hide()
			$Sprite.modulate.a = 1.0
