extends Node3D

@onready var front_desk: Node3D = $"."
@onready var player_service_area: Area3D = $PlayerServiceArea
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var making_coffee_timer: Timer = $MakingCoffeeTimer

const CoffeeCupScene = preload("res://coffee_cup.tscn")

var front_desk_original_material: Material = Material.new() # placeholder
var highlight_material: Material = Material.new() # placeholder

var active_player: Node3D = null
var coffee_cup: Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Coffee maker running")
	coffee_cup = $CoffeeCup
	front_desk_original_material = mesh_instance_3d.get_active_material(0).duplicate()
	highlight_material = front_desk_original_material.duplicate()
	highlight_material.emission_enabled = true
	highlight_material.emission = Color(1, 1, 0.4)
	making_coffee_timer.start()  # TODO require an action with water and coffee beans

func _looks_at_desk(body: Node3D) -> bool:
	var pos_vec = (front_desk.global_position - body.global_position).normalized()
	var direction = (-body.global_transform.basis.z) # Global forward direction
	return pos_vec.dot(direction) > 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player_interacting = active_player and _looks_at_desk(active_player)
	if player_interacting:
		mesh_instance_3d.set_surface_override_material(0, highlight_material)
	else:
		mesh_instance_3d.set_surface_override_material(0, front_desk_original_material)

	var player_action = Input.get_action_strength("player1_action")
	if player_action > 0.5 and player_interacting:
		if coffee_cup and not active_player.currently_carrying:
			active_player.pickup(coffee_cup)
			print("CoffeeMaker hands cup to player")
			making_coffee_timer.start()  # TODO require an action with water and coffee beans


func _on_player_service_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		active_player = body


func _on_player_service_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		active_player = null


func _on_making_coffee_timer_timeout() -> void:
	if coffee_cup:
		return  # already have a cup
	coffee_cup = CoffeeCupScene.instantiate()
	add_child(coffee_cup)
	coffee_cup.global_position = $CoffeeCupPosition.global_position
	print("Made a cup of coffee: ", coffee_cup)
