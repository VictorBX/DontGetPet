extends Node2D

const REVEAL_PERCENT = 0.5

signal did_finish_speech

var text = [
	"Coots...",
	"Coots...",
	"lemme pet u"
]

var current_line = 0
var timer
var speech_started = false

func start():
	$ColorRect/RichTextLabel.percent_visible = 0
	$ColorRect/RichTextLabel.text = text[current_line]
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.start(3.0)
	speech_started = true

func stop():
	timer.stop()

func _process(delta):
	if speech_started:
		var current = $ColorRect/RichTextLabel.percent_visible
		current += REVEAL_PERCENT * delta
		$ColorRect/RichTextLabel.percent_visible = min(current, 1.0)

func _on_timer_timeout():
	current_line += 1
	if current_line >= 3:
		timer.stop()
		emit_signal("did_finish_speech")
		queue_free()
	else:
		$ColorRect/RichTextLabel.percent_visible = 0
		$ColorRect/RichTextLabel.text = text[current_line]
