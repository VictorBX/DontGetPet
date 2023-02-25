extends Node

const BOUNDING_BOX_0 = Vector2(100, 100)
const BOUNDING_BOX_1 = Vector2(150, 150)
const BOUNDING_BOX_2 = Vector2(200, 200)
const BOUNDING_SECTIONS = 3
const BUFFER_BETWEEN_SECTIONS = 10

const ShipBombTarget = preload("res://bosses/ship/ship_bomb_target.tscn")

static func generate_bombs(player_global_position, attack_type):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var bomb_targets = []
	var current_box = 0
	var bombs_per_box = _number_of_bombs_for_attack_type(attack_type)/BOUNDING_SECTIONS
	for i in BOUNDING_SECTIONS:
		for j in bombs_per_box:
			var bomb_target = ShipBombTarget.instance()
			var bomb_point = _random_point_in_bounding_box(i, player_global_position, rng, attack_type)
			bomb_target.global_position = bomb_point
			bomb_targets.append(bomb_target)
	return bomb_targets

static func _random_point_in_bounding_box(box, player_global_position, rng, attack_type):
	if box >= BOUNDING_SECTIONS:
		return Vector2(0, 0)
	var bounding_box = _bounding_box_for_attack_type(attack_type)
	var global_box_xmin = player_global_position.x - bounding_box.x/2
	var global_box_xmax = player_global_position.x + bounding_box.x/2
	var global_box_ymin = player_global_position.y - bounding_box.y/2
	var global_box_ymax = global_box_ymin + _box_height(attack_type)
	var x = rng.randi_range(global_box_xmin, global_box_xmax)
	var y = rng.randi_range(global_box_ymin, global_box_ymax) + (box * (_box_height(attack_type) + BUFFER_BETWEEN_SECTIONS))
	return Vector2(x, y)

static func _box_height(attack_type):
	var bounding_box = _bounding_box_for_attack_type(attack_type)
	return bounding_box.y/BOUNDING_SECTIONS - ((BOUNDING_SECTIONS - 1) * BUFFER_BETWEEN_SECTIONS)

static func _bounding_box_for_attack_type(attack_type):
	if attack_type == 2:
		return BOUNDING_BOX_2
	elif attack_type == 1:
		return BOUNDING_BOX_1
	else:
		return BOUNDING_BOX_0

static func _number_of_bombs_for_attack_type(attack_type):
	if attack_type == 2:
		return 9
	elif attack_type == 1:
		return 6
	else:
		return 3
