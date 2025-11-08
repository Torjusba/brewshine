extends CharacterBody3D

@onready var customer_spawn_location: Node3D = %CustomerSpawnLocation
@onready var customer_purchase_location: Node3D = %CustomerPurchaseLocation
@onready var customer_leave_location: Node3D = %CustomerLeaveLocation

const SPEED = 3.0
var target_position: Vector3 = Vector3.ZERO
var currently_carrying: Node3D = null

func purchase(item: Node3D) -> void:
	if not item:
		return
	item.reparent($CarryingPosition, false)
	item.position = Vector3.ZERO
	currently_carrying = item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = customer_spawn_location.position
	target_position = customer_purchase_location.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var to_move_this_tick = delta * SPEED
	var move_vector = Vector3(target_position - position)
	if move_vector.length() > to_move_this_tick:
		move_vector = move_vector.normalized() * to_move_this_tick
	position += move_vector

	if currently_carrying:
		target_position = customer_leave_location.position
	
	if position.distance_to(customer_leave_location.position) <= 1.0:
		target_position = customer_purchase_location.position
		position = customer_spawn_location.position
		if currently_carrying:
			currently_carrying.queue_free()
			currently_carrying = null
