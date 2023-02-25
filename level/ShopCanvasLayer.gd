extends CanvasLayer

func _process(delta):
	if Input.is_action_just_pressed("ui_pause") && !GlobalState.is_presenting_instructions:
		var paused = !get_tree().paused
		if paused:
			GlobalState.is_presenting_shop = true
			get_parent().display_boss_health(false)
			show()
			get_tree().paused = paused
		else:
			get_parent().display_boss_health(true)
			hide()
			get_tree().paused = paused
			GlobalState.is_presenting_shop = false
