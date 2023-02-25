extends Node2D


func _ready():
	$Tween.interpolate_property(self, "modulate:a", 1.0, 0.0, 1, 3, 1)
	$Tween.connect("tween_completed", self, "on_tween_completed")
	$Tween.start()

func on_tween_completed(one, two):
	queue_free()
