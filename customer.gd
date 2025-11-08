extends CharacterBody3D
class_name Customer3D

# Placeholders
var leave_position: Vector3 = Vector3.ZERO
@onready var queue_ray_cast: RayCast3D = $QueueRayCast

const SPEED = 3.0
var target_position: Vector3 = Vector3.ZERO
var currently_carrying: Node3D = null
var level_manager: LevelManager = null

func purchase(item: Node3D, price: int) -> void:
	if not level_manager:
		print("BUG: Customer purchase() without LevelManager")
	if not item:
		return
	item.reparent($CarryingPosition, false)
	item.position = Vector3.ZERO
	currently_carrying = item
	
	level_manager.add_payment(price)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var to_move_this_tick = delta * SPEED
	var move_vector = Vector3(target_position - position)
	if move_vector.length() > to_move_this_tick:
		move_vector = move_vector.normalized() * to_move_this_tick

	if not queue_ray_cast.is_colliding():
		position += move_vector

	if currently_carrying:
		target_position = leave_position

	if position.distance_to(target_position) <= 0.1:
		rotation_degrees.y = -90
	else:
		rotation_degrees.y = 0
	
	if position.distance_to(leave_position) <= 1.0:
		queue_free()
