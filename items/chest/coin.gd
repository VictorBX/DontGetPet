extends Node2D

const MOVE_TIME = 0.5
const MOVE_SPEED = 70
const MOVE_TO_PLAYER_SPEED = 150
var is_moving = true
var move_timer
var move_direction
var rng = RandomNumberGenerator.new()
var value = 1

func _ready():
	rng.randomize()
	move_direction = Vector2(
		rng.randf_range(-1.0, 1.0),
		rng.randf_range(-1.0, 1.0)
	)
	move_timer = Timer.new()
	move_timer.one_shot = true
	move_timer.connect("timeout", self, "_move_timer_finished")
	add_child(move_timer)
	move_timer.start(MOVE_TIME)

func _process(delta):
	if is_moving:
		# explode from chest
		position += MOVE_SPEED * delta * move_direction
	else:
		# move towards player if nearby
		_move_towards_player(delta)

func _move_timer_finished():
	is_moving = false
	move_timer.queue_free()

func _move_towards_player(delta):
	var player_global_position = get_parent().player_global_position()
	var distance = abs(player_global_position.distance_to(global_position))
	if distance < GlobalPlayer.max_distance_before_coin_moves_towards_player():
		var direction = global_position.direction_to(player_global_position)
		position += MOVE_TO_PLAYER_SPEED * delta * direction

func _on_Area2D_area_entered(area):
	if area.is_in_group("destroy_coin"):
		GlobalPlayer.update_coins(value)
		$AudioStreamPlayer.play()
		yield($AudioStreamPlayer, "finished")
		queue_free()
