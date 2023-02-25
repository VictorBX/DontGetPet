extends YSort

const MIN_HUD_POSITION = Vector2(-256, -256)
const MAX_HUD_POSITION = Vector2(-64, 76)
const BossAction = preload("res://bosses/boss_action.gd")
const LudBase = preload("res://bosses/base/ludbase.tscn")
const LudShip = preload("res://bosses/ship/ludship.tscn")
const LudSpider = preload("res://bosses/spider/ludspider.tscn")
const BossState = preload("res://bosses/boss_state.gd")
const SummonCircle = preload("res://bosses/spider/summon_circle.tscn")
const GlobalLevel = preload("res://state/global_level.gd")

var ludship
var ludspider

var is_paused = false


func _ready():
	GlobalBoss.connect("did_change_boss_state", self, "_did_change_boss_state")
	GlobalBoss.connect("did_finish_speech", self, "_did_finish_speech")
	GlobalBoss.connect("boss_did_die", self, "_on_boss_did_die")
	GlobalPlayer.connect("did_die", self, "_on_did_die")
	$InstructionsCanvasLayer.connect("first_instructions_toggle", self, "_first_instructions_toggle")
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
	$LudBase.connect("ludbase_did_die", self, "_ludbase_did_die")
	start()

func screen_shake():
	$Player/Camera2D.screen_shake()

func player_global_position():
	return $Player.global_position

func start():
	GlobalPlayer.reset()
	GlobalShop.reset()
	$HUDCanvasLayer.hide()
	display_boss_health(false)
	$InstructionsCanvasLayer.show()
	get_tree().paused = true

func display_boss_health(display):
	if display:
		$HUDCanvasLayer/BossHP.show()
	else:
		$HUDCanvasLayer/BossHP.hide()

func _did_change_boss_state(state):
	$P1AudioStreamPlayer.stop()
	$P2AudioStreamPlayer.stop()

func _first_instructions_toggle():
	GlobalBoss.start_speech()
	$AnimationPlayer.play("pan_to_boss")

func _on_animation_finished(animation):
	if animation == "pan_to_boss":
		$LudBase.start_speech()

func _did_finish_speech():
	$HUDCanvasLayer.show()
	display_boss_health(true)
	$CutsceneCamera.current = false
	$Player/Camera2D.current = true
	$ChestSpawner.start()
	$P1AudioStreamPlayer.play()

func _ludbase_did_die():
	ludship = LudShip.instance()
	ludship.global_position = Vector2(0, 0)
	ludship.connect("ludship_did_die", self, "_ludship_did_die")
	add_child(ludship)
	$P2AudioStreamPlayer.play()
	GlobalBoss.change_action(BossAction.BossAction.BA_ATTACKING)

func _ludship_did_die():
	var summon_circle = SummonCircle.instance()
	summon_circle.global_position = Vector2(0, 30)
	summon_circle.connect("summon_done", self, "_summon_circle_done")
	add_child(summon_circle)
	summon_circle.start()

func _summon_circle_done():
	ludspider = LudSpider.instance()
	ludspider.global_position = Vector2(0, 0)
	add_child(ludspider)
	$P2AudioStreamPlayer.play()
	GlobalBoss.change_action(BossAction.BossAction.BA_ATTACKING)

func _on_boss_did_die():
	# do some stuff and then tell state to go to end
	GlobalState.switch(GlobalLevel.GlobalLevel.GL_WIN)

func _on_did_die():
	GlobalState.switch(GlobalLevel.GlobalLevel.GL_LOSE)
