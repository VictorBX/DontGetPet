extends Camera2D

const SHAKE_TIME = 0.3

export var shake_power = 4
var is_shake = false
var cur_pos
var elapsedtime = 0

func _ready():
	randomize()
	cur_pos = offset

func _process(delta):
	if is_shake:
		_shake(delta)

func _shake(delta):
	if elapsedtime < SHAKE_TIME:
		offset =  Vector2(randf(), randf()) * shake_power
		elapsedtime += delta
	else:
		is_shake = false
		elapsedtime = 0
		offset = Vector2(0,0)
		cur_pos = offset

func screen_shake():
	elapsedtime = 0
	is_shake = true
