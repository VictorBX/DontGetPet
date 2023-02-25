extends Node2D

const HealthWidth = 300.0

func _ready():
	GlobalBoss.connect("did_reduce_boss_health", self, "_did_reduce_boss_health")

func _did_reduce_boss_health(current_health_percent):
	var new_length = HealthWidth * current_health_percent
	new_length = max(10.0, new_length)
	$Tween.stop_all()
	$Tween.interpolate_method(self, "_update_point", $Line2D.points[1].x, new_length, 0.2)
	$Tween.start()
	if current_health_percent <= 0:
		queue_free()

func _update_point(new_length):
	$Line2D.set_point_position(1, Vector2(new_length, $Line2D.points[1].y))
