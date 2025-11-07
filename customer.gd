extends StaticBody3D

@onready var customer_spawn_location: Node3D = %CustomerSpawnLocation
@onready var customer_purchase_location: Node3D = %CustomerPurchaseLocation
@onready var customer_leave_location: Node3D = %CustomerLeaveLocation

const SPEED = 3.0

var target_position: Vector3 = Vector3.ZERO
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
