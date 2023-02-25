extends Node2D

const LINE_WIDTH = 1.2
const NUM_OF_LINES = 32
const X_LENGTH = 6.0
const ELLIPSE_MULT = Vector2(1.5, 1.0)
const RED = Color(1.0, 0.0, 0.0)
const LIGHT_RED = Color("ff9898")

var radius = 0
var iteration = 0
var poly_points

func update_target(radius):
	self.radius = radius
	update()

func get_polygon_points():
	return poly_points

func _draw():
	var center = Vector2(0, 0)
	var angle_from = 0
	var angle_to = 360
	var color
	if iteration == 0:
		color = RED
		iteration += 1
	else:
		color = LIGHT_RED
		iteration = 0
	var alpha_color = color
	alpha_color.a = 0.2
	_draw_circle_arc_poly(center, radius, angle_from, angle_to, alpha_color)
	_draw_circle_arc(center, radius, angle_from, angle_to, color)
	_draw_x(center, color)

func _draw_circle_arc(center, radius, angle_from, angle_to, color):
	var points_arc = PoolVector2Array()

	for i in range(NUM_OF_LINES + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / NUM_OF_LINES - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(NUM_OF_LINES):
		draw_line(points_arc[index_point] * ELLIPSE_MULT, points_arc[index_point + 1] * ELLIPSE_MULT, color, LINE_WIDTH)

func _draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var points_arc = PoolVector2Array()
	points_arc.push_back(center)
	var colors = PoolColorArray([color])

	for i in range(NUM_OF_LINES + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / NUM_OF_LINES - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius * ELLIPSE_MULT)
	poly_points = points_arc
	draw_polygon(points_arc, colors)

func _draw_x(center, color):
	var mid_length = X_LENGTH/2.0
	var start_p1 = Vector2(center.x - mid_length, center.y - mid_length)
	var end_p1 = Vector2(center.x + mid_length, center.y + mid_length)
	var start_p2 = Vector2(center.x - mid_length, center.y + mid_length)
	var end_p2 = Vector2(center.x + mid_length, center.y - mid_length)
	draw_line(start_p1, end_p1, color, LINE_WIDTH)
	draw_line(start_p2, end_p2, color, LINE_WIDTH)
