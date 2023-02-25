extends Node2D

signal summon_done

var expand_timer
var remove_timer

func start():
	$CircleSprite.show()
	$Line2D.show()
	$CPUParticles2D.show()
	$AnimationPlayer.play("expand")
	expand_timer = Timer.new()
	expand_timer.one_shot = true
	expand_timer.connect("timeout", self, "_on_expand_timer_timeout")
	add_child(expand_timer)
	expand_timer.start(5)

func _on_expand_timer_timeout():
	$CPUParticles2D.hide()
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 1, 100, 0.2)
	$Tween.start()
	remove_timer = Timer.new()
	remove_timer.one_shot = true
	remove_timer.connect("timeout", self, "_on_remove_timer_timeout")
	add_child(remove_timer)
	remove_timer.start(2)

func _on_remove_timer_timeout():
	emit_signal("summon_done")
	queue_free()
