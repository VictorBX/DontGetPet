extends Node2D

const ShopItemType = preload("res://hud/shop_item_type.gd")

func _ready():
	reset()

func reset():
	$BGColorRect/ItemDescriptionLabel.bbcode_text = ""
	$BGColorRect/LaserShopItem.configure(ShopItemType.ShopItemType.SI_LASER)
	$BGColorRect/LaserShopItem.connect("did_highlight_item", self, "_did_highlight_item")
	$BGColorRect/KnifeShopItem.configure(ShopItemType.ShopItemType.SI_SWORD)
	$BGColorRect/KnifeShopItem.connect("did_highlight_item", self, "_did_highlight_item")
	$BGColorRect/QTShopItem.configure(ShopItemType.ShopItemType.SI_QT_BLESSING)
	$BGColorRect/QTShopItem.connect("did_highlight_item", self, "_did_highlight_item")
	$BGColorRect/LaserJuiceShopItem.configure(ShopItemType.ShopItemType.SI_LASER_JUICE)
	$BGColorRect/LaserJuiceShopItem.connect("did_highlight_item", self, "_did_highlight_item")
	$BGColorRect/LongDashShopItem.configure(ShopItemType.ShopItemType.SI_INCREASE_IFRAMES)
	$BGColorRect/LongDashShopItem.connect("did_highlight_item", self, "_did_highlight_item")
	$BGColorRect/FasterMoveShopItem2.configure(ShopItemType.ShopItemType.SI_FASTER_MOVEMENT)
	$BGColorRect/FasterMoveShopItem2.connect("did_highlight_item", self, "_did_highlight_item")
	$BGColorRect/ReduceDashShopItem3.configure(ShopItemType.ShopItemType.SI_REDUCE_DASH_COOLDOWN)
	$BGColorRect/ReduceDashShopItem3.connect("did_highlight_item", self, "_did_highlight_item")
	$BGColorRect/ReduceGunShopItem4.configure(ShopItemType.ShopItemType.SI_REDUCE_GUN_COOLDOWN)
	$BGColorRect/ReduceGunShopItem4.connect("did_highlight_item", self, "_did_highlight_item")
	$BGColorRect/LuckyShopItem5.configure(ShopItemType.ShopItemType.SI_LUCKY_MANS)
	$BGColorRect/LuckyShopItem5.connect("did_highlight_item", self, "_did_highlight_item")

func _description_for_item(shop_item_type):
	match shop_item_type:
		ShopItemType.ShopItemType.SI_LASER:
			return "Laser\n\nPretty powerful stuff. You need to replenish on laser juice when you run out."
		ShopItemType.ShopItemType.SI_SWORD:
			return "Knife\n\nShort range slashes so you'll need to get up close. It's also pretty sharp.\n\nATTACK POWER: 3x"
		ShopItemType.ShopItemType.SI_QT_BLESSING:
			return "QT's Blessing\n\nIncreases your health by 1. Count your blessings."
		ShopItemType.ShopItemType.SI_LASER_JUICE:
			return "Laser Juice\n\nWhen your laser needs a refill buy this."
		ShopItemType.ShopItemType.SI_INCREASE_IFRAMES:
			return "Increase Invincibility\n\nIncreases invincibility time after getting hit by 1.5x."
		ShopItemType.ShopItemType.SI_FASTER_MOVEMENT:
			return "Faster Movement\n\nIncreases movement speed by 1.3x."
		ShopItemType.ShopItemType.SI_REDUCE_DASH_COOLDOWN:
			return "Reduce Dash Cooldown\n\nReduces cooldown time between dashes by 2x."
		ShopItemType.ShopItemType.SI_REDUCE_GUN_COOLDOWN:
			return "Reduce Shot Cooldown\n\nReduces cooldown time between shots (for gun and knife) by 2x."
		ShopItemType.ShopItemType.SI_LUCKY_MANS:
			return "Greedy Mans\n\nIncreases worth of each coin you collect by 2x and increases your coin magnet radius by 2x."

func _did_highlight_item(highlighted, shop_item_type):
	$BGColorRect/ItemDescriptionLabel.bbcode_text = ""
	if highlighted:
		$BGColorRect/CoinSprite.show()
		$BGColorRect/CoinRichTextLabel.show()
		$BGColorRect/CoinRichTextLabel.text = "%d" % GlobalShop.cost_for_item(shop_item_type)
		$BGColorRect/ItemDescriptionLabel.bbcode_text = _description_for_item(shop_item_type)
	else:
		$BGColorRect/CoinSprite.hide()
		$BGColorRect/CoinRichTextLabel.hide()
