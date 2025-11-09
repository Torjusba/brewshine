extends CharacterBody3D
class_name Player

@onready var animation_player: AnimationPlayer = $base_character/AnimationPlayer
const SPEED = 5.0
const DASH_SPEED := 15.0
const DASH_ACTIVE_DURATION := 0.18
var dash_active_time: float = 0.0
var currently_carrying: Item3D = null
var is_attempting_action: bool = false

func pickup(item: Item3D) -> void:
	if currently_carrying:
		print("Player can't pickup, is already carrying")
		return
	print("Pickup")
	item.reparent($CarryingPosition, false)
	item.position = Vector3.ZERO
	currently_carrying = item
	print("Picked up ", currently_carrying)

var action_was_down: bool = false
func _process(_delta: float) -> void:
	var action_input = Input.get_action_strength("player1_action")
	var action_is_down: bool = action_input > 0.5

	is_attempting_action = action_is_down and not action_was_down

	action_was_down = action_is_down


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Dash input -> use %DashTimer as cooldown only
	if Input.is_action_just_pressed("player1_dash") and %DashTimer.is_stopped():
		%DashTimer.start() # starts cooldown
		dash_active_time = DASH_ACTIVE_DURATION
		var forward = - transform.basis.z
		forward.y = 0
		forward = forward.normalized()
		velocity.x = forward.x * DASH_SPEED
		velocity.z = forward.z * DASH_SPEED

	var direction: Vector3 = Vector3.ZERO
	if dash_active_time > 0.0:
		# Active dash phase
		dash_active_time -= delta
		var forward = - transform.basis.z
		forward.y = 0
		forward = forward.normalized()
		velocity.x = forward.x * DASH_SPEED
		velocity.z = forward.z * DASH_SPEED
		direction = forward
	else:
		# Normal movement
		var input_dir := Input.get_vector("player1_left", "player1_right", "player1_up", "player1_down")
		var camera_forward = -%MainSceneCamera.global_transform.basis.z
		var camera_right = %MainSceneCamera.global_transform.basis.x
		camera_forward.y = 0
		camera_right.y = 0
		camera_forward = camera_forward.normalized()
		camera_right = camera_right.normalized()
		if input_dir.length() > 0:
			direction = (camera_right * input_dir.x + camera_forward * -input_dir.y).normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	if not direction.is_zero_approx():
		transform.basis = Basis.looking_at(direction)
		if dash_active_time > 0.0:
			# TODO: animation_player.play("Dash")
			pass
		else:
			animation_player.play("WalkCycle")
	else:
		animation_player.play("Idle")
	move_and_slide()
