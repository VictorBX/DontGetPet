extends Node

const GlobalLevel = preload("res://state/global_level.gd")

var level = GlobalLevel.GlobalLevel.GL_MENU
var previous_scene = null
var current_scene = null
var transition_screen
var is_transitioning
var new_scene
var tree
var is_presenting_instructions = true
var is_presenting_shop = false

func _ready():
	self.tree = get_tree()
	current_scene = tree.get_current_scene()
	current_scene.connect("did_tap_start_game", self, "_start_level")
	
	var packed_scene = load("res://menu/transition_screen.tscn")
	self.transition_screen = packed_scene.instance()
	self.transition_screen.connect("did_finish_appear_animation", self, "_did_finish_transition_appear_animation")
	self.tree.get_root().call_deferred("add_child",self.transition_screen)

func _start_level():
	switch(GlobalLevel.GlobalLevel.GL_FIGHT)
	
func switch(level):
	if self.level == level:
		return
	self.level = level
	previous_scene = current_scene
	match level:
		GlobalLevel.GlobalLevel.GL_MENU:
			_transition_to_scene("res://menu/menu.tscn")
		GlobalLevel.GlobalLevel.GL_FIGHT:
			_transition_to_scene("res://level/MainLevel.tscn")
		GlobalLevel.GlobalLevel.GL_WIN:
			_transition_to_scene("res://menu/end_screen.tscn")
		GlobalLevel.GlobalLevel.GL_LOSE:
			_transition_to_scene("res://menu/end_screen.tscn")

func _transition_to_scene(scene):
	if !self.is_transitioning:
		self.is_transitioning = true
		self.new_scene = scene
		self.transition_screen.begin_transition()

func _did_finish_transition_appear_animation():
	var packed_scene = load(new_scene)
	if previous_scene != null:
		previous_scene.queue_free()
		previous_scene = null
	current_scene = packed_scene.instance()
	
	tree.get_root().add_child(current_scene)
	match self.level:
		GlobalLevel.GlobalLevel.GL_MENU:
			_config_menu(current_scene)
		GlobalLevel.GlobalLevel.GL_FIGHT:
			_config_fight(current_scene)
		GlobalLevel.GlobalLevel.GL_WIN:
			_config_end(current_scene, true)
		GlobalLevel.GlobalLevel.GL_LOSE:
			_config_end(current_scene, false)
	tree.set_current_scene(current_scene)
	self.is_transitioning = false

func reset():
	is_presenting_instructions = true
	is_presenting_shop = false
	
	GlobalPlayer.reset()
	GlobalShop.reset()
	GlobalBoss.reset()

func _config_menu(menu):
	menu.connect("did_tap_start_game", self, "_start_level")

func _config_fight(fight):
	pass

func _config_end(end, is_winner):
	reset()
	end.configure(is_winner)
