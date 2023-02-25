extends Sprite

const Player = preload("res://player/player.gd")

var player_state

func update_state(player_state):
	if self.player_state == player_state:
		return
	self.player_state = player_state
	match player_state:
		Player.PlayerState.PS_IDLE:
			$AnimationPlayer.stop()
			rotation_degrees = 0
		Player.PlayerState.PS_RUNNING:
			$AnimationPlayer.play("running", -1, 2.0)
		Player.PlayerState.PS_DASHING:
			$AnimationPlayer.stop()
			rotation_degrees = 0
		Player.PlayerState.PS_DYING:
			$AnimationPlayer.stop()
			rotation_degrees = 0
