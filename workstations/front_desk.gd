extends Node3D

@onready var front_desk: Node3D = $"."
@onready var player_service_area: Area3D = $PlayerServiceArea
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

var front_desk_original_material: Material = Material.new() # placeholder
var highlight_material: Material = Material.new() # placeholder

var active_player: Player = null
var active_customer: Customer3D = null
var active_customers = Array()

const DEFAULT_PRICE: int = 1
const COFFEE_PRICE: int = 5
const MOONSHINE_PRICE: int = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	front_desk_original_material = mesh_instance_3d.get_active_material(0).duplicate()
	highlight_material = front_desk_original_material.duplicate()
	highlight_material.emission_enabled = true
	highlight_material.emission = Color(1, 1, 0.4)

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

	if player_interacting and active_player.is_attempting_action:
		if not active_customers.is_empty():
			if active_player.currently_carrying:
				print("Handing ", active_player.currently_carrying, " to customer")
				var customer = active_customers.pop_front()
				var price: int = DEFAULT_PRICE
				if active_player.currently_carrying.item_name == "Coffee":
					price = COFFEE_PRICE
				elif active_player.currently_carrying.item_name == "Moonshine":
					price = MOONSHINE_PRICE

				customer.purchase(active_player.currently_carrying, price)
				active_player.currently_carrying = null



func _on_player_service_area_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		active_player = body
		print("Player entered desk")


func _on_player_service_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		active_player = null
		print("Player left desk")


func _on_customer_area_body_entered(body: Node3D) -> void:
	if body is Customer3D:
		active_customers.append(body)
