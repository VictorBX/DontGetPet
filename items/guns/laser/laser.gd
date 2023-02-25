extends RayCast2D

const CAST_MAX = 1000 
var is_casting = false

func fire():
	set_is_casting(true)
	
func stop():
	set_is_casting(false)

func _ready():
	set_physics_process(false)
	$Line2D.points[1] = Vector2(0,0)

func _physics_process(delta):
	var cast_point = cast_to
	force_raycast_update()
	
	$CollisionCPUParticles2D.emitting = _is_colliding_with_non_player(delta)
	
	if _is_colliding_with_non_player(delta):
		cast_point = to_local(get_collision_point())
		$CollisionCPUParticles2D.global_rotation = get_collision_normal().angle()
		$CollisionCPUParticles2D.position = cast_point
	$Line2D.points[1] = cast_point
	$BoxCPUParticles2D.position = cast_point * 0.5
	$BoxCPUParticles2D.emission_rect_extents.x = cast_point.length() * 0.5

func _is_colliding_with_non_player(delta):
	if is_colliding():
		var collider = get_collider()
		if collider.is_in_group("destroy_bullet"):
			if collider.is_in_group("boss"):
				GlobalBoss.hit_by_laser_bullet(delta)
			if collider.is_in_group("chest"):
				collider.get_parent().destroy()
			return true
	return false

func set_is_casting(cast):
	is_casting = cast
	
	$BoxCPUParticles2D.emitting = is_casting
	$MuzzleCPUParticles2D.emitting = is_casting
	if is_casting:
		_laser_appear()
	else:
		$CollisionCPUParticles2D.emitting = false
		_laser_disappear()
	set_physics_process(cast)

func _laser_appear():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 0, 5, 0.2)
	$Tween.start()

func _laser_disappear():
	$Tween.stop_all()
	$Tween.interpolate_property($Line2D, "width", 5, 0, 0.1)
	$Tween.start()
