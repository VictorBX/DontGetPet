extends AnimatedSprite

const GunType = preload("res://items/guns/gun_type.gd")

func _ready():
	connect("animation_finished", self, "_on_animation_finished")
	
func configure(gun):
	match gun:
		GunType.GunType.GT_POLAR_STAR:
			play("polar_star")

func _on_animation_finished():
	queue_free()
