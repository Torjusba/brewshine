extends CharacterBody3D
class_name Player

@onready var animation_player: AnimationPlayer = $base_character/AnimationPlayer
const SPEED = 5.0
var currently_carrying: Node3D = null


func pickup(item: Node3D) -> void:
	if currently_carrying:
		print("Player can't pickup, is already carrying")
		return
	print("Pickup")
	item.reparent($CarryingPosition, false)
	item.position = Vector3.ZERO
	currently_carrying = item
	print("Picked up ", currently_carrying)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("player1_left", "player1_right", "player1_up", "player1_down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if not direction.is_zero_approx():
		transform.basis = Basis.looking_at(direction)
		animation_player.play("WalkCycle")
	else:
		animation_player.play("Idle")
	move_and_slide()
