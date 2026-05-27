extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var ray = $head/RayCast3D
@onready var interact_label = get_node("/root/level/CanvasLayer/InteractLabel")

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Movement
	var input_dir := Input.get_vector("left", "right", "forward", "backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func _process(delta):
	if ray.is_colliding():
		var hit = ray.get_collider()
		# Go up the tree to find the interactable node
		var node = hit
		var found = null
		while node != null:
			if node.is_in_group("interactable"):
				found = node
				break
			node = node.get_parent()
		
		if found != null:
			interact_label.visible = true
			if Input.is_action_just_pressed("interact"):
				found.inspect()
		else:
			interact_label.visible = false
	else:
		interact_label.visible = false
