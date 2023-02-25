extends Node

const BOSS_TOTAL_HEALTH = 1000.0
const BossState = preload("res://bosses/boss_state.gd")
const BossAction = preload("res://bosses/boss_action.gd")

signal did_reduce_boss_health
signal did_change_boss_state
signal did_change_boss_action
signal did_finish_speech
signal boss_did_die
signal is_halfway_second_phase
signal is_halfway_third_phase

var boss_health = 1000.0
var boss_state = BossState.BossState.BS_BASE
var boss_action = BossAction.BossAction.BA_TALKING
var is_speeching = false

func _ready():
	reset()
	
func reset():
	boss_health = BOSS_TOTAL_HEALTH
	boss_state = BossState.BossState.BS_BASE
	boss_action = BossAction.BossAction.BA_TALKING
	is_speeching = false

func start_speech():
	GlobalPlayer.can_player_do_anything = false
	is_speeching = true
	change_action(BossAction.BossAction.BA_TALKING)

func finish_speech():
	GlobalPlayer.can_player_do_anything = true
	is_speeching = false
	change_action(BossAction.BossAction.BA_ATTACKING)
	emit_signal("did_finish_speech")

func finish_transform():
	change_action(BossAction.BossAction.BA_ATTACKING)

func hit_by_polar_bullet():
	reduce_health(2)

func hit_by_laser_bullet(delta):
	reduce_health(10 * delta)

func hit_by_knife_bullet():
	reduce_health(6)

func reduce_health(amount):
	if boss_action != BossAction.BossAction.BA_ATTACKING:
		return
	boss_health -= amount
	var boss_health_chunk = BOSS_TOTAL_HEALTH/3.0
	if boss_health <= 0:
		emit_signal("boss_did_die")
		emit_signal("did_reduce_boss_health", 0)
		return
	if boss_health <= boss_health_chunk:
		next_state(BossState.BossState.BS_SPIDER)
	elif boss_health <= boss_health_chunk * 2.0:
		next_state(BossState.BossState.BS_SHIP)
	
	if boss_health <= boss_health_chunk * 0.5:
		emit_signal("is_halfway_third_phase")
	elif boss_health <= boss_health_chunk * 1.5:
		emit_signal("is_halfway_second_phase")
	emit_signal("did_reduce_boss_health", boss_health/BOSS_TOTAL_HEALTH)

func next_state(state):
	if boss_state == state:
		return
	boss_state = state
	change_action(BossAction.BossAction.BA_TRANSFORMING)
	emit_signal("did_change_boss_state", state)

func change_action(action):
	if boss_action == action:
		return
	boss_action = action
	emit_signal("did_change_boss_action", action)
