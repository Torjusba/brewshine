extends Node3D
class_name LevelManager

const POLICE_RATE: float = 0.2
const WANTS_MOONSHINE_RATE: float = 0.5
const BASE_CUSTOMER_DELAY = 3
const CUSTOMER_RANDOM_DELAY = 10

@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var customer_spawn_location: Node3D = $CustomerSpawnLocation
@onready var customer_leave_location: Node3D = $CustomerLeaveLocation
@onready var customer_purchase_location: Node3D = $CustomerPurchaseLocation

@export var garage_gate: GarageGate

const CustomerScene = preload("res://customer.tscn")
const PolicemanScene = preload("res://policeman.tscn")

var seconds_to_next_customer: float = 0.0
var current_money: int = 0;
@onready var lose_canvas: CanvasLayer = $LoseCanvas
@onready var loss_reason_label: Label = $LoseCanvas/ColorRect/LossReasonLabel

func lose(reason: String = "") -> void:
	loss_reason_label.text = reason
	lose_canvas.visible = true
	Engine.time_scale = 0

func add_payment(money: int) -> void:
	current_money += money
	score_label.text = "$" + str(current_money)

func spawn_new_customer() -> void:
	var new_customer: Customer3D = null
	var should_spawn_policeman: bool = randf() <= POLICE_RATE
	if should_spawn_policeman:
		new_customer = PolicemanScene.instantiate()
		new_customer.name = "Customer"
		new_customer.garage_gate = garage_gate
	else:
		new_customer = CustomerScene.instantiate()
		new_customer.name = "Customer"

	new_customer.position = customer_spawn_location.position
	new_customer.target_position = customer_purchase_location.position
	new_customer.leave_position = customer_leave_location.position
	new_customer.level_manager = self
	new_customer.wants_moonshine = randf() >= WANTS_MOONSHINE_RATE
	add_child(new_customer)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lose_canvas.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if seconds_to_next_customer <= 0.0:
		print("Spawning new customer")
		spawn_new_customer()
		seconds_to_next_customer = BASE_CUSTOMER_DELAY + randf() * CUSTOMER_RANDOM_DELAY

	seconds_to_next_customer -= delta


func _on_replay_button_pressed() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale = 1.0
