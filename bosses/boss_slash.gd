extends Bullet

const SPEED = 100
var direction

func configure(rotation, direction):
	self.rotation = rotation
	self.direction = direction

func _process(delta):
	position += direction * delta * SPEED

func _on_Area2D_area_entered(area):
	destroy_slash(area)

func _on_Area2D_body_entered(body):
	destroy_slash(body)

func destroy_slash(object):
	if object.is_in_group("destroy_enemy_bullet") && !(object.is_in_group("is_invincible") || object.is_in_group("is_iframes")):
		if object.is_in_group("player"):
			GlobalPlayer.hit_by_enemy()
		$AnimatedSprite.play("disappear")

func _on_AnimatedSprite_animation_finished():
	destroy_bullet()
