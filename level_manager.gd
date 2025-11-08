extends Node3D
class_name LevelManager

@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var customer_spawn_location: Node3D = $CustomerSpawnLocation
@onready var customer_leave_location: Node3D = $CustomerLeaveLocation
@onready var customer_purchase_location: Node3D = $CustomerPurchaseLocation

const CustomerScene = preload("res://customer.tscn")

var seconds_to_next_customer: float = 0.0
var current_money: int = 0;

func add_payment(money: int) -> void:
	current_money += money
	score_label.text = "$" + str(current_money)

func spawn_new_customer() -> void:
	var new_customer: Customer3D = CustomerScene.instantiate()
	new_customer.name = "Customer"
	new_customer.position = customer_spawn_location.position
	new_customer.target_position = customer_purchase_location.position
	new_customer.leave_position = customer_leave_location.position
	new_customer.level_manager = self
	new_customer.wants_moonshine = randf() >= 0.5
	add_child(new_customer)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if seconds_to_next_customer <= 0.0:
		print("Spawning new customer")
		spawn_new_customer()
		seconds_to_next_customer = 2.0 + randf() * 3.0

	seconds_to_next_customer -= delta
