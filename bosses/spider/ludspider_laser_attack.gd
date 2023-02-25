extends Node2D

const MOVE_ANGLE = 200
signal boss_laser_done
var pincer_timer
var should_move = false

func _ready():
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
	pincer_timer = Timer.new()
	pincer_timer.connect("timeout", self, "_time_to_pincer")
	pincer_timer.one_shot = true
	add_child(pincer_timer)

func configure(angle):
	self.rotation = angle
	$RightLudSpiderLaser.fire()
	$LeftLudSpiderLaser.fire()
	pincer_timer.start(3)

func _process(delta):
	if should_move:
		var new_right_angle = $RightLudSpiderLaser.rotation_degrees + (MOVE_ANGLE * delta)
		$RightLudSpiderLaser.rotation_degrees = min(0, new_right_angle)
		var new_left_angle = $LeftLudSpiderLaser.rotation_degrees - (MOVE_ANGLE * delta)
		$LeftLudSpiderLaser.rotation_degrees = max(0, new_left_angle)
		if new_right_angle <= 0:
			emit_signal("boss_laser_done")
			queue_free()

func _time_to_pincer():
	$AnimationPlayer.play("pinch")

func _on_animation_finished(animation):
	emit_signal("boss_laser_done")
	queue_free()
