extends Node2D

signal did_tap_start_game
var did_tap_start = false

onready var music_bus = AudioServer.get_bus_index("Music")
onready var sfx_bus = AudioServer.get_bus_index("SFX")

func _ready():
	$QButton.connect("pressed", self, "_on_q_pressed")
	$FGColorRect/XButton.connect("pressed", self, "_on_x_pressed")
	$FGColorRect/MusicHSlider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))
	$FGColorRect/SFXHSlider.value = db2linear(AudioServer.get_bus_volume_db(sfx_bus))

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") && !did_tap_start:
		did_tap_start = true
		emit_signal("did_tap_start_game")

func _on_q_pressed():
	$BGColorRect.show()
	$FGColorRect.show()

func _on_x_pressed():
	$BGColorRect.hide()
	$FGColorRect.hide()

func _on_MusicHSlider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear2db(value))

func _on_SFXHSlider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus, linear2db(value))
