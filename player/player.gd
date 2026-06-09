extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var ray = $head/RayCast3D
@onready var interact_label = get_node("/root/level/CanvasLayer/InteractLabel")

var hold_timer = 0.0
var hold_threshold = 0.2

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
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
	# Block all interaction while inspecting
	if InspectManager.is_inspecting:
		interact_label.visible = false
		hold_timer = 0.0
		return
	
	if ray.is_colliding():
		var hit = ray.get_collider()
		var node = hit
		var found = null
		while node != null:
			if node.is_in_group("interactable"):
				found = node
				break
			node = node.get_parent()
		
		if found != null:
			interact_label.visible = true
			
			if Input.is_action_pressed("interact"):
				hold_timer += delta
				var progress = int((hold_timer / hold_threshold) * 100)
				interact_label.text = "[ Hold E ] Inspect... " + str(progress) + "%"
				if hold_timer >= hold_threshold:
					hold_timer = 0.0
					found.inspect()
			else:
				hold_timer = 0.0
				interact_label.text = "[ Hold E ] Inspect"
		else:
			hold_timer = 0.0
			interact_label.visible = false
	else:
		hold_timer = 0.0
		interact_label.visible = false
