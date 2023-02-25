extends Node

const CHEST = preload("res://items/chest/chest.tscn")
const Bounds = 216
const CHEST_TIME = 45

var current_chests = []
var reset_timer
var rng = RandomNumberGenerator.new()

func start():
	rng.randomize()
	_create_chests()
	reset_timer = Timer.new()
	reset_timer.connect("timeout", self, "_on_reset_timer_timeout")
	add_child(reset_timer)
	reset_timer.start(CHEST_TIME)

func _on_reset_timer_timeout():
	_create_chests()

# health, coin_amount, value_per_coin
func _create_chests():
	if !current_chests.empty():
		for chest in current_chests:
			if chest != null && is_instance_valid(chest):
				chest.queue_free()
		current_chests = []
	
	var amount = 3
	for i in amount:
		var health = 100
		var type = rng.randi_range(1, 10)
		var value_per_coin = 5
		var rare = 1
		if type == 1:
			health = 300
			rare = 3
			value_per_coin = 25
		elif type == 2 || type == 3:
			health = 200
			rare = 2
			value_per_coin = 10
		var chest = CHEST.instance()
		chest.configure(health, 35, value_per_coin, rare)
		chest.global_position = _get_random_position()
		get_parent().add_child(chest)
		current_chests.append(chest)

func _get_random_position():
	var x = rng.randi_range(-Bounds, Bounds)
	var y = rng.randi_range(-Bounds, Bounds)
	return Vector2(x, y)
