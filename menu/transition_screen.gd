extends Node2D

const TIME_THRESHOLD = 0.05
var current_time = 0
var is_animating = false
var is_appearing = true
var progress = 0

signal did_finish_appear_animation

func _ready():
	$CanvasLayer/ColorRect.visible = false

func _process(delta):
	if self.is_animating:
		self.current_time += delta
		if self.current_time > TIME_THRESHOLD:
			self.current_time = 0
			_update_progress()

func begin_transition():
	self.is_animating = true
	$CanvasLayer/ColorRect.visible = true
	$CanvasLayer/ColorRect.material.set_shader_param("isAppearing", self.is_appearing)
	
func _update_progress():
	if self.progress + 0.1 > 1:
		if self.is_appearing:
			emit_signal("did_finish_appear_animation")
			self.is_appearing = false
			$CanvasLayer/ColorRect.material.set_shader_param("isAppearing", self.is_appearing)
			self.progress = 0.1
		else:
			_reset()
			return
	else:
		self.progress += 0.1
	$CanvasLayer/ColorRect.material.set_shader_param("progress", self.progress)

func _reset():
	$CanvasLayer/ColorRect.visible = false
	$CanvasLayer/ColorRect.material.set_shader_param("isAppearing", true)
	$CanvasLayer/ColorRect.material.set_shader_param("progress", 0)
	self.is_animating = false
	self.is_appearing = true
	self.progress = 0
	self.current_time = 0
