extends CanvasLayer

signal first_instructions_toggle
var is_first_toggle = true

func _process(delta):
	if Input.is_action_just_pressed("ui_instructions"):
		toggle_instructions()

func toggle_instructions():
	var paused = !get_tree().paused
	if is_first_toggle:
		is_first_toggle = false
		hide()
		get_tree().paused = paused
		emit_signal("first_instructions_toggle")
	
	if GlobalState.is_presenting_shop:
		return
	
	if paused:
		GlobalState.is_presenting_instructions = true
		get_parent().display_boss_health(false)
		show()
		get_tree().paused = paused
	else:
		get_parent().display_boss_health(true)
		hide()
		get_tree().paused = paused
		GlobalState.is_presenting_instructions = false
