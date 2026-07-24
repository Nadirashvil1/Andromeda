extends Node

var held_item: RigidBody3D = null
var cam: Camera3D = null
var hold_distance = 1.5
var move_force = 25.0
var max_hold_distance = 3.0

func start_grab(item: RigidBody3D, camera: Camera3D):
	held_item = item
	cam = camera
	held_item.gravity_scale = 0.0
	held_item.linear_damp = 10.0
	held_item.angular_damp = 10.0
	held_item.collision_layer = held_item.collision_layer  # keep colliding with world
	held_item.set_collision_mask_value(1, true)             # still collides with world layer

func stop_grab():
	if held_item:
		held_item.gravity_scale = 1.0
		held_item.linear_damp = 0.0
		held_item.angular_damp = 0.0
	held_item = null
	cam = null

func _physics_process(delta):
	if not held_item or not cam:
		return

	var target_pos = cam.global_position + (-cam.global_transform.basis.z * hold_distance)

	# If too far from target (item stuck on geometry), drop it
	if held_item.global_position.distance_to(target_pos) > max_hold_distance:
		stop_grab()
		return

	var to_target = target_pos - held_item.global_position
	held_item.linear_velocity = to_target * move_force * delta * 60.0

func adjust_distance(delta_scroll: float):
	hold_distance = clamp(hold_distance + delta_scroll, 0.5, max_hold_distance)
