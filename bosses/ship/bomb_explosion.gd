extends AnimatedSprite

var explode_timer
var rng = RandomNumberGenerator.new()

func _ready():
	connect("animation_finished", self, "_on_animation_finished")
	explode_timer = Timer.new()
	explode_timer.one_shot = true
	explode_timer.connect("timeout", self, "_on_explode")
	add_child(explode_timer)
	rng.randomize()
	explode_timer.start(rng.randf_range(0.0, 0.3))

func _on_explode():
	show()
	play("explode")

func _on_animation_finished():
	queue_free()
