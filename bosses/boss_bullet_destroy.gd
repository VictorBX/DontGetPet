extends AnimatedSprite

const BossGunType = preload("res://bosses/boss_gun_type.gd")

func _ready():
	connect("animation_finished", self, "_on_animation_finished")
	
func configure(gun):
	match gun:
		BossGunType.BossGunType.BGT_SMALL_RED:
			play("small_red")

func _on_animation_finished():
	queue_free()
