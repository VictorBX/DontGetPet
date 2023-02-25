extends Node2D

const GlobalLevel = preload("res://state/global_level.gd")
const NotPetTexture = preload("res://assets/other/not-pet.png")
const GotPetTexture = preload("res://assets/other/got-pet.png")

func configure(is_winner):
	if is_winner:
		$RichTextLabel.bbcode_text = "[center]You didn't get pet :)[/center]"
		$Sprite.texture = NotPetTexture
	else:
		$RichTextLabel.bbcode_text = "[center]You got pet :([/center]"
		$Sprite.texture = GotPetTexture
	var end_timer = Timer.new()
	end_timer.one_shot = true
	end_timer.connect("timeout", self, "_on_end_timer_timeout")
	add_child(end_timer)
	end_timer.start(5.0)


func _on_end_timer_timeout():
	GlobalState.switch(GlobalLevel.GlobalLevel.GL_MENU)
