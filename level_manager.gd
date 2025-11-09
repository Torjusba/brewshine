extends Node3D
class_name LevelManager

const POLICE_RATE: float = 0.2
const WANTS_MOONSHINE_RATE: float = 0.5
const BASE_CUSTOMER_DELAY = 3
const CUSTOMER_RANDOM_DELAY = 8

@onready var score_label: Label = $CanvasLayer/ScoreLabel
@onready var customer_spawn_location: Node3D = $CustomerSpawnLocation
@onready var customer_leave_location: Node3D = $CustomerLeaveLocation
@onready var customer_purchase_location: Node3D = $CustomerPurchaseLocation

@export var garage_gate: GarageGate

@onready var camera: Camera3D = %MainSceneCamera

const CustomerScene = preload("res://characters/NPCs/customer.tscn")
const PolicemanScene = preload("res://characters/NPCs/policeman.tscn")

var seconds_to_next_customer: float = 0.0
var current_money: int = 0
const MONEY_NEEDED_TO_WIN: int = 100
const TIME_LIMIT_SECONDS: int = 180
@onready var round_limit_timer: Timer = $RoundLimitTimer

@onready var lose_canvas: CanvasLayer = $LoseCanvas
@onready var loss_reason_label: Label = $LoseCanvas/ColorRect/LossReasonLabel
@onready var timelimit_progressbar: ProgressBar = $CanvasLayer/ProgressBar
@onready var iron_bars: TextureRect = $LoseCanvas/IronBars
@onready var you_lose_label: Label = $LoseCanvas/ColorRect/YouLoseLabel

var customer_spawn_area_occupied: int = 0

func lose(reason: String = "", should_jail: bool = true) -> void:
	if not should_jail:
		iron_bars.visible = false
		you_lose_label.text = "You failed!"
	loss_reason_label.text = reason
	lose_canvas.visible = true
	Engine.time_scale = 0

func win() -> void:
	iron_bars.visible = false
	you_lose_label.text = "You win!"
	loss_reason_label.text = "You made $" + str(current_money)
	lose_canvas.visible = true
	Engine.time_scale = 0


func add_payment(money: int) -> void:
	current_money += money
	score_label.text = "$" + str(current_money)  + " / $" + str(MONEY_NEEDED_TO_WIN)

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
		new_customer.wants_moonshine = randf() <= WANTS_MOONSHINE_RATE


	new_customer.camera = camera
	new_customer.position = customer_spawn_location.position
	new_customer.target_position = customer_purchase_location.position
	new_customer.leave_position = customer_leave_location.position
	new_customer.level_manager = self
	add_child(new_customer)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lose_canvas.visible = false
	add_payment(0)  # to init the score label correctly
	round_limit_timer.start(TIME_LIMIT_SECONDS)
	timelimit_progressbar.max_value = TIME_LIMIT_SECONDS


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if seconds_to_next_customer <= 0.0 and not customer_spawn_area_occupied:
		print("Spawning new customer")
		spawn_new_customer()
		seconds_to_next_customer = BASE_CUSTOMER_DELAY + randf() * CUSTOMER_RANDOM_DELAY

	seconds_to_next_customer -= delta
	timelimit_progressbar.value = round_limit_timer.time_left
	if (current_money >= MONEY_NEEDED_TO_WIN):
		win()


func _on_replay_button_pressed() -> void:
	get_tree().reload_current_scene()
	Engine.time_scale = 1.0


func _on_customer_spawn_area_body_entered(_body: Node3D) -> void:
	customer_spawn_area_occupied += 1


func _on_customer_spawn_area_body_exited(_body: Node3D) -> void:
	customer_spawn_area_occupied -= 1


func _on_round_limit_timer_timeout() -> void:
	lose("You did not make enough money in time", false)
